# --- Navigation ---
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lah --color=auto'
alias la='ls -A --color=auto'
alias ls='ls --color=auto'

# --- Safety ---
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# --- Kitty scrollback clear ---
alias clearall='printf "\033[H\033[2J\033[3J"'

# --- ddcutil (suppress spurious i2c-0 errors) ---
alias ddcutil='command ddcutil 2> >(grep -vE "/dev/i2c-0|i2c_permissions" >&2)'

# --- System ---
alias syslog='journalctl -xe'
alias ports='ss -tulnp'
alias myip='ip -br a'

# --- dnf shortcuts ---
alias dnfi='sudo dnf install'
alias dnfs='dnf search'
alias dnfu='sudo dnf upgrade'

# --- Git ---
alias gs='git status'
alias gl='git log --oneline --graph --decorate'
alias gd='git diff'


alias vim='nvim'
