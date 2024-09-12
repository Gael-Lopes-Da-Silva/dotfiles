#!/bin/bash

pacman -S --noconfirm xorg xorg-xinit xclip maim
pacman -S --noconfirm upower brightnessctl network-manager-applet

cd /home/gael/.config/dwm
make clean install

cd /home/gael/.config/dmenu
make clean install

cd /home/gael/.config/dwmblocks
make clean install

echo -e "xsetroot -solid \"#474747\"\nbash -c \"nm-applet\" &\nbash -c \"dwmblocks\" &\nexec dwm" >> /home/gael/.xinitrc
chmod 755 /home/gael/.xinitrc
