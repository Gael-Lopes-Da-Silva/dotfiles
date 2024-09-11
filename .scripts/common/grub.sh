#!/bin/bash

grub-mkfont -s 32 -o /boot/grub/fonts/cascadia_mono_nf.pf2 /usr/share/fonts/TTF/CascadiaMonoNF.ttf
echo -e 'GRUB_FONT="/boot/grub/fonts/cascadia_mono_nf.pf2"' >> /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfn
