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
alias cp='cp -priv'
alias rm='rm -rfIdv'
alias mv='mv -iv'
alias zed='zeditor'

alias compress='ouch compress'
alias decompress='ouch decompress'

alias shutdown='systemctl poweroff'
alias reboot='systemctl reboot'
alias suspend='systemctl suspend'

alias paru='paru --bottomup'
alias install='paru -S'
alias search='paru -Ss'
alias update='paru -Syu'
alias remove='paru -Rns'
alias infos='paru -Qi'
alias list='paru -Qe'
alias owns='paru -Qo'
alias clean='paru -Qdtq | paru -Rns -'

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

PS1='\[\e[92;1m\]\w\[\e[0m\]\n$(exit_code=$?; if [[ $exit_code -ne 0 ]]; then printf "\[\e[91;1m\]\[\e[0m\]"; else printf "\[\e[90;1m\]\[\e[0m\]"; fi) '
PS2='\[\e[90;1m\]\[\e[0m\] '
