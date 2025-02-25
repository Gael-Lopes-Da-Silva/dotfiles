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

export GTK2_RC_FILES=~/.config/gtk-2.0/settings.ini
export GTK_THEME=Adwaita-dark

[[ $(tty) == "/dev/tty1" ]] && exec startx
