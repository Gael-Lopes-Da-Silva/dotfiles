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

bash ~/.scripts/soundboard.sh

[[ $(tty) == "/dev/tty1" ]] && exec startx
