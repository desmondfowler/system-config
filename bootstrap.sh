#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ln -sf "$REPO/.config/nvim"        "$HOME/.config/nvim" # managed by nvim-config repo
ln -sf "$REPO/home/.bashrc"        "$HOME/.bashrc"
ln -sf "$REPO/home/.zshrc"         "$HOME/.zshrc"
ln -sf "$REPO/home/.zshenv"        "$HOME/.zshenv"
ln -sf "$REPO/home/.zshrc.d"       "$HOME/.zshrc.d"
# ln -sf "$REPO/.config/kitty"      "$HOME/.config/kitty" # moving to foot
ln -sf "$REPO/.config/MangoHud"   "$HOME/.config/MangoHud"
ln -sf "$REPO/.config/btop" "$HOME/.config/btop"
ln -sf "$REPO/.config/foot"             "$HOME/.config/foot"
ln -sf "$REPO/.config/tmux"             "$HOME/.config/tmux"
ln -sf "$REPO/.config/tmux-sessionizer" "$HOME/.config/tmux-sessionizer"

# Symlink individual scripts into ~/.local/bin rather than the whole bin/ dir
mkdir -p "$HOME/.local/bin"
for script in "$REPO/bin/"*; do
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
done
