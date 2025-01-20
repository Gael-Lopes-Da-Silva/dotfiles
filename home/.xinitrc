#!/bin/bash

pgrep -x nm-applet || nm-applet &
pgrep -x dwmblocks || dwmblocks &
pgrep -x dunst || dunst &
pgrep -x udiskie || udiskie --automount --notify --tray &

eval "$(gnome-keyring-daemon --start)"
export SSH_AUTH_SOCK

export GTK2_RC_FILES=~/.config/gtk-2.0/settings.ini

dbus-update-activation-environment --systemd DISPLAY XAUTHORITY &

xsetroot -solid "#474747"
xsetroot -cursor_name left_ptr
xset r rate 250 40
xset s off -dpms

exec dwm
