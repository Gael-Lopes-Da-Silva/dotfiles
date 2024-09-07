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
PS1="\e[0;31m\w "; export PS1
