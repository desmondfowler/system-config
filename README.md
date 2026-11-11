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

## Manual steps / state outside the repo

Install nvm, then install the current LTS Node.js and set it as the default:

```sh
nvm install --lts && nvm alias default 'lts/*'
```

`bootstrap.sh` clones `~/.powerlevel10k` at the commit pinned by `P10K_SHA` in `bootstrap.sh`.
To update the theme, change that pin to the desired commit SHA.

The Lean prompt works without a Nerd Font. To use the icon styles, install MesloLGS NF and select it
in the terminal profile. Rerunning `p10k configure` rewrites `home/.p10k.zsh`, including the color
edits; review the diff or save a copy first.

Tailscale settings live in tailscaled state, not in this repo, so a rebuild won't recreate them; re-run after a fresh install.

- `sudo tailscale set --accept-dns=true` - MagicDNS routing via systemd-resolved; without it, `*.ts.net` names don't resolve
- `sudo tailscale serve --bg 5006` - HTTPS proxy to the Actual container on `127.0.0.1:5006`; Actual needs a secure
  context for SharedArrayBuffer, so plain HTTP on the LAN IP fails. Result: https://zenith.banded-polaris.ts.net/ (tailnet-only)

## Restic (Zenith) backup

- `bin/restic-zenith-backup` gathers system state and runs the Zenith backup modes.
- `bin/restic-zenith-new` loads its private env file and invokes Restic with the configured repository and credentials.
- `.config/restic/zenith-new.excludes.example` is a generic template; the real `~/.config/restic/zenith-new.excludes` stays local because it contains machine-specific paths.
- `restic-zenith-weekly.service` runs the backup; its timer schedules it daily at 23:00.
- `restic-zenith-prune.service` prunes old snapshots; its timer runs Mondays at 12:00.
- `restic-zenith-check.service` checks the repository; its timer schedules periodic checks.
- `restic-zenith-notify@.service` is the notification template used by the jobs.

Wrapper env files, password files, and `restic.master.env` are deliberately untracked. The Zenith wrapper's private env file is `~/.config/restic/restic-zenith-new.env`; keep it owner-only. Password copies live in a password manager entry and a paper copy. No password values or repository identifiers belong in this repo.

### Restore on a fresh machine

Create the private env and password files out of band, copy the example excludes file to the local path above and fill in machine-specific patterns, then run from the repo root:

```sh
REPO="$PWD"
mkdir -p "$HOME/.local/bin" "$HOME/.config/restic" "$HOME/.config/systemd/user"
cp -n .config/restic/zenith-new.excludes.example "$HOME/.config/restic/zenith-new.excludes"
chmod 600 "$HOME/.config/restic/restic-zenith-new.env"
ln -s "$REPO/bin/restic-zenith-backup" "$HOME/.local/bin/restic-zenith-backup"
ln -s "$REPO/bin/restic-zenith-new" "$HOME/.local/bin/restic-zenith-new"
for unit in \
  restic-zenith-weekly.service restic-zenith-weekly.timer \
  restic-zenith-prune.service restic-zenith-prune.timer \
  restic-zenith-check.service restic-zenith-check.timer \
  'restic-zenith-notify@.service'; do
  ln -s "$REPO/.config/systemd/user/$unit" "$HOME/.config/systemd/user/$unit"
done
systemctl --user daemon-reload
systemctl --user enable --now restic-zenith-weekly.timer restic-zenith-prune.timer restic-zenith-check.timer
```
