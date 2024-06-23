if status is-interactive
    and not set -q TMUX
    exec tmux
end

set fish_greeting

alias c="clear"
alias n="nvim"
alias t="tmux"
alias l="eza -al --icons"

zoxide init fish | source
