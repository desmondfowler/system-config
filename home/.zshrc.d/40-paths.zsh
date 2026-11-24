# Keep PATH free of duplicates across re-sourcing and nested shells.
typeset -U path PATH

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
export PATH="$PATH:$HOME/.local/share/go/bin"
export PATH="$PATH:$HOME/.cargo/bin"
