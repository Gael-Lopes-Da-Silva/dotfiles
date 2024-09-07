#!/bin/sh

PKG="xorg i3 i3status i3blocks i3lock dmenu kitty xclip xdotool maim"

pkg install -y $PKG

echo "dbus_enable=\"YES\"" >> /etc/rc.conf
echo "hald_enable=\"YES\"" >> /etc/rc.conf
echo "exec /usr/local/bin/i3" > ~/.xinitrc
