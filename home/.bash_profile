#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR="nvim"
export VISUAL="nvim"
export TERMINAL="kitty"
export BROWSER="chromium"
export GTK_THEME="Adwaita:dark"
export SUDO_PROMPT="Password: "
export VDPAU_DRIVER="va_gl"

export PATH="$PATH:~/.cargo/bin"

[[ $(tty) == "/dev/tty1" ]] && exec startx
