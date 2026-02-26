#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER="nvim +Man!"
export GIT_EDITOR="nvim"
export GIT_PAGER="less"
export TERMINAL="alacritty"
export BROWSER="firefox"
export PAGER="less"
export LESS="-R -F -X"
export MANPAGER="less -R"
export LESSHISTFILE="-"
export TERM="xterm-256color"
export COLORTERM="truecolor"
export VDPAU_DRIVER="va_gl"
export MOZ_ENABLE_WAYLAND=1

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
export HISTIGNORE="ls:cd:cd -:pwd:exit:clear"
export HISTTIMEFORMAT='%F %T '
export PATH="$HOME/.local/bin:$HOME/.cargo/bin:$PATH"

export GTK_THEME=Adwaita:dark
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_STYLE_OVERRIDE=Fusion
export QT_QUICK_CONTROLS_STYLE=Fusion
