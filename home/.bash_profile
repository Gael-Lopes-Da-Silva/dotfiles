#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='kitty'
export BROWSER='chromium'
export GTK_THEME='Adwaita:dark'

export PATH=$PATH:~/.cargo/bin

[[ $(tty) == "/dev/tty1" ]] && exec dbus-run-session startx
