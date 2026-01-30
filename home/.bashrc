#
# ~/.bashrc
#

[[ $- != *i* ]] && return

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias dir='dir --color=auto'
alias vdir='vdir --color=auto'
alias ls='ls --color=auto --sort=extension --group-directories-first'
alias la='ls -Alh'
alias ll='ls -lh'
alias cp='cp -prv'
alias rm='rm -rfIdv'
alias mv='mv -v'

alias compress='ouch compress'
alias decompress='ouch decompress'

bind 'set show-all-if-ambiguous on'
bind 'set mark-symlinked-directories on'
bind 'set completion-ignore-case on'
bind 'set colored-stats on'
bind 'set enable-bracketed-paste off'

bind 'TAB:menu-complete'
bind '"\e[A":history-search-backward'
bind '"\e[B":history-search-forward'

shopt -s checkwinsize
shopt -s histappend
shopt -s autocd
shopt -s dirspell
shopt -s cdspell
shopt -s cmdhist
shopt -s globstar
shopt -s extglob

HISTCONTROL=ignoredups:erasedups
HISTSIZE=1000
HISTFILESIZE=2000
PROMPT_COMMAND=get_prompt

RESET="\[\e[0m\]"
GREEN="\[\e[92;1m\]"
RED="\[\e[91;1m\]"

function get_prompt {
    if [ "$?" -eq "0" ]; then
        PROMPT="${GREEN}\w${RESET}"
    else
        PROMPT="${RED}\w${RESET}"
    fi

    PS1="${PROMPT}\n"
}
