#!/bin/sh

grub-mkfont -s 32 -o /boot/grub/fonts/CascadiaMonoNF.pf2 /usr/share/fonts/TTF/CascadiaMonoNF.ttf
echo 'FONT="/boot/grub/fonts/CascadiaMonoNF.pf2"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfn
