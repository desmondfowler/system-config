# Simple two-color prompt: user@host path %
# Easy to extend later
autoload -Uz colors && colors

PROMPT='%F{166}[%n@%m]%f %F{214}%~%f %# '
