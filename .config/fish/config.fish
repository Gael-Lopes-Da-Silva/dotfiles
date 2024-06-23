if status is-interactive
    # Commands to run in interactive sessions can go here
end

set fish_greeting

alias c="clear"
alias n="nvim"
alias l="eza -al --icons"

zoxide init fish | source
