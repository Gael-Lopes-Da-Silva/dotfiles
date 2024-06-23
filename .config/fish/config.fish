if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CLIENT
    and not set -q SSH_TTY
    exec tmux
end

set fish_greeting

alias c="clear"
alias n="nvim"
alias t="tmux"
alias l="eza -al --icons"

zoxide init fish | source
