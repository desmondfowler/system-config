# Use vi-style keybindings (default zsh)
bindkey -v
export KEYTIMEOUT=1 

# History search with up/down arrows
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search    # up arrow
bindkey '^[[B' down-line-or-beginning-search  # down arrow

# Ctrl+Left / Ctrl+Right word navigation
bindkey '^[[1;5D' backward-word
bindkey '^[[1;5C' forward-word

# Home / End
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line

# Delete key
bindkey '^[[3~' delete-char

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'  # block cursor in normal mode
  else
    echo -ne '\e[6 q'  # beam cursor in insert mode
  fi
}
zle -N zle-keymap-select

function zle-line-init {
  echo -ne '\e[6 q'  # beam on new prompt (insert mode)
}
zle -N zle-line-init
