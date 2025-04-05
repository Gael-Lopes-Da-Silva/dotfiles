#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='kitty'
export BROWSER='chromium'
export COLORTERM='truecolor'
export PAGER='less -r'
export GTK_THEME=Adwaita-dark
export QT_STYLE_OVERRIDE=Adwaita-Dark
export VDPAU_DRIVER=va_gl

export PATH=$PATH:~/.scripts/:~/.cargo/bin

[[ $(tty) == "/dev/tty1" ]] && exec startx
