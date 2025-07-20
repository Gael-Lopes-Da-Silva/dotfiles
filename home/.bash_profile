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
export SUDO_PROMPT='Password: '

export PATH=$PATH:~/.cargo/bin

[[ $(tty) == "/dev/tty1" ]] && exec startx
