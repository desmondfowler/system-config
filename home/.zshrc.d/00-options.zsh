# --- History ---
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_DUPS       # don't record duplicate of previous command
setopt HIST_IGNORE_ALL_DUPS   # remove older duplicate entries
setopt HIST_FIND_NO_DUPS      # don't show dupes when searching
setopt HIST_REDUCE_BLANKS     # strip superfluous blanks
setopt INC_APPEND_HISTORY     # write to history immediately, not on shell exit
setopt SHARE_HISTORY          # share history across sessions

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

# --- Plugins (system-installed) ---
source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

export EDITOR=nvim
export VISUAL=nvim

autoload -Uz bracketed-paste-magic
zle -N bracketed-paste bracketed-paste-magic
