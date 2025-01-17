#!/bin/bash

nm-applet &
dwmblocks &
dunst &
udiskie --automount --notify --tray &
gnome-keyring-daemon --start &

xsetroot -solid "#474747"

exec dbus-launch --sh-syntax --exit-with-session dwm