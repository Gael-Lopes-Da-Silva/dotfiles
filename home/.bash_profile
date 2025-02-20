#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export BROWSER='firefox'
export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='st'
export COLORTERM='truecolor'
export PAGER='less -r'

[[ $(tty) == "/dev/tty1" ]] && exec startx
