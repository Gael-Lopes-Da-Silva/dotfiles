#
# Exports:
#
ENV=$HOME/.profile; export ENV
PATH=$HOME/.cargo/bin:$PATH; export PATH
HISTFILE=$HOME/.history; export HISTFILE

EDITOR=nvim;  export EDITOR
PAGER=less;   export PAGER

#
# Logic:
#
if [ "$PWD" != "$HOME" ] && [ $PWD -ef "$HOME" ]; then cd; fi
if [ -x /usr/bin/resizewin ]; then /usr/bin/resizewin -z; fi
if [ -x /usr/bin/fortune ]; then /usr/bin/fortune freebsd-tips; fi

#
# Alias:
#
alias h="fc -l"
alias j="jobs"
alias m="$PAGER"
alias g="egrep -i"

alias cp="cp -ip"
alias mv="mv -i"
alias rm="rm -i"

alias ls="ls --color"
alias ll="ls -l --color"
alias la="ls -lA --color"
alias lg="lazygit"
alias vim="nvim"

#
# Keybinds:
#
bind ^[[A ed-search-prev-history
bind ^[[B ed-search-next-history

bind "\\e[1;5C" em-next-word
bind "\\e[1;5D" ed-prev-word

bind ^[[5~ ed-move-to-beg
bind ^[[6~ ed-move-to-end

#
# Prompt:
#
# RESET=$(tput me)
# BG_BLUE=$(tput AB 4)
#
# PS1="\w "; export PS1
TC_NORM="$(tput me)"
TC_RED="$(tput AF 1)"
TC_GREEN="$(tput AF 2)"
TC_YELLOW="$(tput AF 3)"
TC_BLUE="$(tput AF 4)"
TC_MAGENTA="$(tput AF 5)"
TC_CYAN="$(tput AF 6)"
TC_WHITE="$(tput AF 7)"

PS1="${TC_CYAN}\u${TC_RED}@${TC_YELLOW}\h${TC_GREEN}%${TC_NORM} "
