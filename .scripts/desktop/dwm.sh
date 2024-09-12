#!/bin/bash

pacman -S --noconfirm xorg xorg-xinit xss-lock xclip maim
pacman -S --noconfirm upower brightnessctl network-manager-applet

cd /home/gael/.config/dwm
make clean install

echo -e "xsetroot -solid \"#474747\"; nm-applet; exec dwm" >> $HOME/.xinitrc
