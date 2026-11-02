# system-config

Dotfiles and machine config for a Fedora KDE box. `./bootstrap.sh` symlinks everything into place
(existing real files are moved to `*.bak.<timestamp>`); it is safe to re-run.

## Layout

- `home/` - files that live directly in `~` (shell rc, `.gitconfig`, `.ssh/config`, agent tool settings)
- `.config/` - mirrors `~/.config` (alacritty, tmux, git, input-remapper, Vial, quadlets, ...)
- `.config/kde/` - KDE files, _copied_ by bootstrap (KDE replaces symlinks); `bin/kde-snapshot` copies live changes back
- `bin/` - scripts linked into `~/.local/bin`
- `share/applications/` - custom `.desktop` launchers (Steam-generated shortcuts are not tracked)

## Not tracked

Secrets live outside the repo; examples are provided: `.config/lotro/lotro.env.example`,
`.config/restic/restic.env.example`, `home/.gitconfig.local.example` (git name/email).
The repo is public, so no names, emails or home paths are committed; `.desktop` files use `@HOME@`,
which bootstrap substitutes. Keys (`~/.ssh/fedora-github`, `.gnupg`) are never stored here.

## Packages assumed

zsh (+ zsh-autosuggestions, zsh-syntax-highlighting), fzf, tmux, alacritty, wl-clipboard, btop,
git, **gh**, restic, libsecret (`secret-tool`), podman, input-remapper.

## Post-install (state held outside the repo)

Both settings live in tailscaled state, not in this repo, so a rebuild won't recreate them; re-run after a fresh install.

- `sudo tailscale set --accept-dns=true` - MagicDNS routing via systemd-resolved; without it, `*.ts.net` names don't resolve
- `sudo tailscale serve --bg 5006` - HTTPS proxy to the Actual container on `127.0.0.1:5006`; Actual needs a secure
  context for SharedArrayBuffer, so plain HTTP on the LAN IP fails. Result: https://zenith.banded-polaris.ts.net/ (tailnet-only)
