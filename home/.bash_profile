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

export GTK_THEME=Adwaita:dark
export QT_STYLE_OVERRIDE=Adwaita-Dark

[[ $(tty) == "/dev/tty1" ]] && exec startx
