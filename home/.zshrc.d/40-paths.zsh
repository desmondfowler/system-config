# Keep PATH free of duplicates across re-sourcing and nested shells.
typeset -U path PATH

export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.local/share/bob/nvim-bin:$PATH"
