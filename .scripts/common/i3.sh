#!/bin/sh

PKG="xorg i3 i3status i3blocks i3lock dmenu kitty xclip xdotool maim"

pkg install -y $PKG

sysrc dbus_enable=YES
sysrc hald_enable=YES

echo "exec /usr/local/bin/i3" > ~/.xinitrc
