#!/bin/bash

[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

pgrep -x nm-applet || nm-applet &
pgrep -x dwmblocks || dwmblocks &
pgrep -x dunst || dunst &
pgrep -x udiskie || udiskie --automount --notify --tray &

eval "$(gnome-keyring-daemon --start)"
export SSH_AUTH_SOCK

dbus-update-activation-environment --systemd DISPLAY XAUTHORITY &

xsetroot -solid "#474747"
xsetroot -cursor_name left_ptr
xset r rate 250 40
xset s off -dpms

systemctl --user restart soundboard.service &

exec dwm
