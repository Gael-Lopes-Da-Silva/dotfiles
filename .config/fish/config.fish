if status is-interactive
    and not set -q TMUX
    and not set -q SSH_CLIENT
    and not set -q SSH_TTY
    exec tmux
end

set fish_greeting

fish_vi_key_bindings
set -g fish_vi_force_cursor 1
set fish_cursor_default block
set fish_cursor_insert line
set fish_cursor_replace_one underscore

alias c="clear"
alias n="nvim"
alias t="tmux"
alias l="eza -al --icons"

zoxide init fish | source
