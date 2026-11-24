# usb.zsh -- batch workflow for imaging/recovering old USB sticks (zsh only)
# Per stick:  usbgo   (image -> recover named files -> carve JPEGs -> dedupe/validate)
# Needs: ddrescue sleuthkit jpeginfo python3.  Override the target with USB_ROOT=...
: ${USB_ROOT:=/mnt/sata-data/usb-sticks}

_usb_root() {
  [ -d "$USB_ROOT" ] && [ "$(findmnt -n -o TARGET -T "$USB_ROOT")" != / ] \
    || { echo "USB_ROOT=$USB_ROOT missing or on / (disk not mounted?)" >&2; return 1; }
}

usbls() { lsblk -d -o NAME,SIZE,TRAN,MODEL | awk 'NR==1||$3=="usb"'; }

usbcheck() {
  local p i c d bad=0
  p=$(readlink -f "/sys/block/${1##*/}/device" 2>/dev/null)
  while [ -n "$p" ] && [ "$p" != / ] && [ ! -e "$p/idVendor" ]; do p=${p%/*}; done
  [ -e "$p/idVendor" ] || { echo "${1##*/}: not a USB device" >&2; return 2; }
  echo "$(cat "$p/idVendor"):$(cat "$p/idProduct") $(cat "$p/manufacturer" 2>/dev/null) $(cat "$p/product" 2>/dev/null)"
  for i in "$p"/*:*; do
    c=$(cat "$i/bInterfaceClass")
    d=$(readlink -f "$i/driver" 2>/dev/null); d=${d##*/}
    printf '  %s class=%s driver=%s\n' "${i##*/}" "$c" "${d:-none}"
    [ "$c" = 08 ] || bad=1
  done
  if [ $bad = 0 ]; then echo "OK: mass-storage interfaces only"
  else echo "WARNING: non-mass-storage interface present" >&2; return 1; fi
}

usbimg() {
  local d=${1##*/} out s base info rc
  _usb_root || return
  out=$USB_ROOT/usb-images
  if [ -z "$d" ]; then
    d=$(lsblk -dno NAME,TRAN | awk '$2=="usb"{print $1}')
    [ -n "$d" ] && [ "$(echo "$d" | wc -l)" = 1 ] || { echo "need exactly one USB disk, or pass one (usbls)" >&2; return 1; }
  fi
  info=$(usbcheck "$d" 2>&1); rc=$?
  echo "$info"
  case $rc in 0) ;; 1) [ -n "$USB_FORCE" ] || return 1 ;; *) return 1 ;; esac
  s=$(udevadm info -q property -n "/dev/$d" | sed -n 's/^ID_SERIAL_SHORT=//p')
  mkdir -p "$out" || return
  base=$out/$(date +%Y%m%d-%H%M%S)-${s:-noserial}
  echo "$info" > "$base.info"
  sudo ddrescue "/dev/$d" "$base.img" "$base.map" || return
  sudo chown "$USER:" "$base.img" "$base.map" || return
  ( cd "$out" && sha256sum "${base##*/}.img" | tee "${base##*/}.sha256" ) || return
  USB_LAST=$base.img
}

usbmnt() {
  local img=${1:-$USB_LAST} l part
  l=$(sudo losetup -r -P -f --show "$img") || return
  udevadm settle
  part=$l; [ -b "${l}p1" ] && part=${l}p1
  sudo mkdir -p /mnt/usbtest
  sudo mount -o ro,noexec,nosuid,nodev "$part" /mnt/usbtest && echo "$part -> /mnt/usbtest"
}

usbumnt() {
  local s pk
  s=$(findmnt -n -o SOURCE /mnt/usbtest) || { echo "nothing mounted" >&2; return 1; }
  sudo umount /mnt/usbtest || return
  pk=$(lsblk -no PKNAME "$s" 2>/dev/null)
  sudo losetup -d "/dev/${pk:-${s##*/}}"
}

usbtriage() {
  local img=${1:-$USB_LAST} src
  src=$(findmnt -n -o SOURCE /mnt/usbtest) || { echo "nothing mounted" >&2; return 1; }
  echo "files: $(find /mnt/usbtest -type f | wc -l)   used: $(df -h --output=used /mnt/usbtest | tail -1 | xargs)"
  echo "non-zero bytes in image: $(tr -d '\0' < "$img" | wc -c)"
  echo "deleted entries (first 20):"; sudo fls -r -d "$src" 2>/dev/null | head -20
}

# Named recovery (allocated + deleted entries) straight from the image; no mount needed.
usbrecover() {
  local img=${1:-$USB_LAST} out l p dest
  local -a parts
  _usb_root || return
  out=$USB_ROOT/usb-recovered/$(basename "${img%.img}")
  l=$(sudo losetup -r -P -f --show "$img") || return
  udevadm settle
  parts=( ${l}p*(N) )
  (( ${#parts} )) || parts=( $l )
  mkdir -p "$out"
  for p in $parts; do
    dest=$out; (( ${#parts} > 1 )) && dest=$out/${p:t}
    mkdir -p "$dest"
    echo "== $p -> $dest"
    sudo tsk_recover -e "$p" "$dest" 2>&1 | tail -2
  done
  sudo losetup -d "$l"
  sudo chown -R "$USER:" "$out"
  echo "recovered: $(find "$out" -type f | wc -l) files, $(du -sh "$out" | cut -f1)"
}

# Signature carve: split the image at JPEG start markers (names lost; offset order kept).
usbcarve() {
  local img=${1:-$USB_LAST} out
  _usb_root || return
  out=$USB_ROOT/carved/$(basename "${img%.img}")
  python3 - "$img" "$out" <<'PY'
import mmap, os, re, sys
img, out = sys.argv[1], sys.argv[2]
MAX, MIN = 64 << 20, 2048
os.makedirs(out, exist_ok=True)
n = 0
if os.path.getsize(img):
    with open(img, 'rb') as f:
        m = mmap.mmap(f.fileno(), 0, access=mmap.ACCESS_READ)
        offs = [x.start() for x in re.finditer(rb'\xff\xd8\xff[\xe0\xe1]', m)] + [len(m)]
        for a, b in zip(offs, offs[1:]):
            chunk = m[a:min(b, a + MAX)]
            e = chunk.rfind(b'\xff\xd9')
            if e < MIN:
                continue
            with open(f'{out}/{n:04d}_{a:010d}.jpg', 'wb') as o:
                o.write(chunk[:e + 2])
            n += 1
print(f'carved {n} jpegs -> {out}')
PY
}

# Carved files whose hash isn't already in the recovered set -> <id>-new/, plus validation reports.
usbmerge() {
  local img=${1:-$USB_LAST} id rec car new have
  _usb_root || return
  id=$(basename "${img%.img}")
  rec=$USB_ROOT/usb-recovered/$id car=$USB_ROOT/carved/$id new=$USB_ROOT/carved/$id-new
  [ -d "$car" ] || { echo "run usbcarve first" >&2; return 1; }
  have=$(mktemp)
  [ -d "$rec" ] && find "$rec" -type f -exec sha256sum {} + | cut -d' ' -f1 | sort -u > "$have"
  mkdir -p "$new"
  find "$car" -maxdepth 1 -name '*.jpg' -exec sha256sum {} + | sort -u -k1,1 \
    | awk 'FILENAME==ARGV[1]{h[$1];next} !($1 in h){print $2}' "$have" - \
    | xargs -r -I{} cp --reflink=auto -- {} "$new/"
  rm -f "$have"
  find "$new" -maxdepth 1 -name '*.jpg' -exec jpeginfo -c {} + 2>/dev/null \
    | grep -E 'ERROR|WARNING' > "$new/_damaged.txt"
  [ -d "$rec" ] && find "$rec" -iname '*.jpg' -exec jpeginfo -c {} + 2>/dev/null \
    | grep -E 'ERROR|WARNING' > "$new/_recovered-bad.txt"
  echo "carved-new: $(find "$new" -maxdepth 1 -name '*.jpg' | wc -l)   damaged: $(wc -l < "$new/_damaged.txt")   recovered-but-bad: $(wc -l < "$new/_recovered-bad.txt" 2>/dev/null)"
}

# Move JPEG-named recovered files that fail validation into quarantine/ (reversible, paths preserved).
usbquarantine() {
  local img=${1:-$USB_LAST} id rec q new f rel n=0 c
  _usb_root || return
  id=$(basename "${img%.img}")
  rec=$USB_ROOT/usb-recovered/$id q=$USB_ROOT/quarantine/$id new=$USB_ROOT/carved/$id-new
  [ -d "$rec" ] || { echo "nothing recovered for $id" >&2; return 1; }
  while IFS= read -r -d '' f; do
    jpeginfo -c -- "$f" >/dev/null 2>&1 && continue
    rel=${f#$rec/}
    mkdir -p "$q/${rel:h}" && mv -- "$f" "$q/$rel" && n=$((n+1))
  done < <(find "$rec" -type f \( -iname '*.jpg' -o -iname '*.jpeg' \) -print0)
  c=$(find "$new" -maxdepth 1 -name '*.jpg' 2>/dev/null | wc -l)
  echo "quarantined: $n bad named jpegs -> $q   (carved-new: $c)"
  (( c < n )) && echo "WARNING: fewer carved-new than quarantined; some photos may exist only as corrupt named copies (try photorec on the image)" >&2
  return 0
}

# One command per stick.
usbgo() {
  usbimg "$@" || return
  local id; id=$(basename "${USB_LAST%.img}")
  echo "image complete -- safe to unplug the stick now"
  echo "data bytes in image: $(tr -d '\0' < "$USB_LAST" | wc -c)"
  usbrecover; usbcarve; usbmerge; usbquarantine
  echo "---- done: $id ----"
}
