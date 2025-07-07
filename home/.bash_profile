#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='kitty'
export BROWSER='chromium'
export COLORTERM='truecolor'
export GTK_THEME='Adwaita:dark'

export PATH=$PATH:~/.scripts/:~/.cargo/bin

[[ $(tty) == "/dev/tty1" ]] && exec startx
