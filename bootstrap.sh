#!/usr/bin/env bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

ln -sf "$REPO/.config/nvim"        "$HOME/.config/nvim"
ln -sf "$REPO/home/.bashrc"        "$HOME/.bashrc"
ln -sf "$REPO/home/.zshrc"         "$HOME/.zshrc"
ln -sf "$REPO/home/.zshenv"        "$HOME/.zshenv"
ln -sf "$REPO/home/.zshrc.d"       "$HOME/.zshrc.d"

# Symlink individual scripts into ~/.local/bin rather than the whole bin/ dir
mkdir -p "$HOME/.local/bin"
for script in "$REPO/bin/"*; do
    ln -sf "$script" "$HOME/.local/bin/$(basename "$script")"
done
