# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate entries
setopt HIST_FIND_NO_DUPS      # don't show dupes when searching
setopt HIST_REDUCE_BLANKS     # strip superfluous blanks
setopt SHARE_HISTORY          # share history across sessions (implies incremental append)

# --- Completion ---
autoload -Uz compinit
compinit

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' rehash true  # pick up newly installed commands

# --- General options ---
setopt AUTO_CD              # cd by typing directory name
setopt CORRECT              # suggest corrections for mistyped commands
setopt NO_BEEP
setopt INTERACTIVE_COMMENTS # allow # comments in interactive shell (fixes zsh gotcha)

export EDITOR=nvim
export VISUAL=nvim

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
