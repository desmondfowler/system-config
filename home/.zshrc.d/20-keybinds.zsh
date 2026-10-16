# Use vi-style keybindings (zsh defaults to emacs; this resets all keymaps,
# so keep it first). KEYTIMEOUT is in 1/100s: short ESC delay, but long
# enough for escape sequences to arrive intact.
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

# Home / End (^[[1~ / ^[[4~: variants sent inside tmux)
bindkey '^[[H' beginning-of-line
bindkey '^[[F' end-of-line
bindkey '^[[1~' beginning-of-line
bindkey '^[[4~' end-of-line

# Emacs-style line editing in insert mode (bindkey -v drops these)
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line
bindkey '^K' kill-line
bindkey '^U' backward-kill-line
bindkey '^W' backward-kill-word

# Backspace can erase past the point where insert mode started
bindkey '^?' backward-delete-char

# Shift+Tab goes backwards through the completion menu
bindkey '^[[Z' reverse-menu-complete

# Normal mode: v edits the current line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -a 'v' edit-command-line

# Delete key
bindkey '^[[3~' delete-char

# Ctrl+Delete / Ctrl+Backspace delete whole words
# (unbound, Ctrl+Delete's ESC prefix drops zsh into vi normal mode)
bindkey '^[[3;5~' kill-word
bindkey '^H' backward-kill-word
bindkey -a '^[[3;5~' kill-word
bindkey -a '^H' backward-kill-word

# History search
# bindkey '^R' history-incremental-search-backward

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
