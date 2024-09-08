#!/bin/sh

pacman -S --noconfirm ly
systemctl enable ly.service
sed -i "s/sleep_cmd = null/sleep_cmd = systemctl suspend/" /etc/ly/config.ini

pacman -S --noconfirm terminus-font
setfont ter-132n
echo "FONT=ter-132n" >> /etc/vconsole.conf
