# system-config

Dotfiles and machine config for a Fedora KDE box. `./bootstrap.sh` symlinks everything into place
(existing real files are moved to `*.bak.<timestamp>`); it is safe to re-run.

## Layout
- `home/` - files that live directly in `~` (shell rc, `.gitconfig`, `.ssh/config`, agent tool settings)
- `.config/` - mirrors `~/.config` (alacritty, foot, tmux, git, input-remapper, Vial, quadlets, ...)
- `.config/kde/` - KDE files, *copied* by bootstrap (KDE replaces symlinks); `bin/kde-snapshot` copies live changes back
- `bin/` - scripts linked into `~/.local/bin`
- `share/applications/` - custom `.desktop` launchers (Steam-generated shortcuts are not tracked)

## Not tracked
Secrets live outside the repo; examples are provided: `.config/lotro/lotro.env.example`,
`.config/restic/restic.env.example`, `home/.gitconfig.local.example` (git name/email).
The repo is public, so no names, emails or home paths are committed; `.desktop` files use `@HOME@`,
which bootstrap substitutes. Keys (`~/.ssh/fedora-github`, `.gnupg`) are never stored here.

## Packages assumed
zsh (+ zsh-autosuggestions, zsh-syntax-highlighting), fzf, tmux, alacritty, foot, wl-clipboard, btop,
git, **gh**, restic, libsecret (`secret-tool`), podman, input-remapper.
