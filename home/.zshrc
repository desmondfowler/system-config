# Source all files in ~/.zshrc.d in order
for f in ~/.zshrc.d/*.zsh(N); do
  source "$f"
done
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.cargo/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
