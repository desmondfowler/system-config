# Source all files in ~/.zshrc.d in order
for f in ~/.zshrc.d/*.zsh(N); do
  source "$f"
done
