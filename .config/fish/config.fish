if status is-interactive
    # Commands to run in interactive sessions can go here
end

alias n="nvim"
alias l="eza -al --icons"
alias lt="eza -al --icons --tree --level=2 --long"

zoxide init fish | source
