#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# link <repo-relative source> <absolute destination>
# Idempotent: -n stops ln from descending into an existing directory symlink
# (which would create the link inside the repo). Anything real at the destination
# is moved aside rather than clobbered or nested into.
link() {
    local src="$REPO/$1" dst="$2"
    mkdir -p "$(dirname "$dst")"
    if [[ -e "$dst" || -L "$dst" ]] && [[ ! -L "$dst" ]]; then
        local backup="$dst.bak.$(date +%Y%m%d%H%M%S)"
        echo "backing up $dst -> $backup"
        mv "$dst" "$backup"
    fi
    ln -sfn "$src" "$dst"
}

# link .config/nvim -- managed by nvim-config repo
link home/.bashrc                 "$HOME/.bashrc"
link home/.zshrc                  "$HOME/.zshrc"
link home/.zshenv                 "$HOME/.zshenv"
link home/.zshrc.d                "$HOME/.zshrc.d"
link home/.gitconfig              "$HOME/.gitconfig"

mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
link home/.ssh/config             "$HOME/.ssh/config"

# Agent tool settings (no skills, runtime state, history or caches)
link home/.claude/settings.json   "$HOME/.claude/settings.json"
link home/.copilot/settings.json  "$HOME/.copilot/settings.json"
link home/.copilot/agents         "$HOME/.copilot/agents"

# link .config/kitty              "$HOME/.config/kitty" # replaced by foot, then alacritty
link .config/alacritty            "$HOME/.config/alacritty"
link .config/foot                 "$HOME/.config/foot" # kept in case I switch back
link .config/MangoHud             "$HOME/.config/MangoHud"
link .config/btop                 "$HOME/.config/btop"
link .config/tmux                 "$HOME/.config/tmux"
link .config/git                  "$HOME/.config/git"
link .config/input-remapper-2     "$HOME/.config/input-remapper-2"
link .config/Vial                 "$HOME/.config/Vial"
link .config/containers/systemd   "$HOME/.config/containers/systemd"

# KDE rewrites these files by replacing them, which would destroy a symlink, so they are
# copied in rather than linked. Pull live changes back into the repo with bin/kde-snapshot.
for f in "$REPO/.config/kde/"*; do
    cp -f "$f" "$HOME/.config/$(basename "$f")"
done

# Symlink individual scripts into ~/.local/bin rather than the whole bin/ dir
mkdir -p "$HOME/.local/bin"
for script in "$REPO/bin/"*; do
    link "bin/$(basename "$script")" "$HOME/.local/bin/$(basename "$script")"
done

# Launchers: .desktop files can't expand $HOME, so @HOME@ is substituted and the result copied.
mkdir -p "$HOME/.local/share/applications"
for desktop in "$REPO/share/applications/"*.desktop; do
    dst="$HOME/.local/share/applications/$(basename "$desktop")"
    [[ -L "$dst" ]] && rm "$dst"
    sed "s|@HOME@|$HOME|g" "$desktop" > "$dst"
done

[[ -f "$HOME/.gitconfig.local" ]] || echo "warning: ~/.gitconfig.local missing (git user.name/email); see home/.gitconfig.local.example"

# Untracked config you need to create by hand:
#   ~/.gitconfig.local          (see home/.gitconfig.local.example)
#   ~/.config/lotro/lotro.env   (see .config/lotro/lotro.env.example)
#   ~/.config/restic/restic.env (see .config/restic/restic.env.example)
