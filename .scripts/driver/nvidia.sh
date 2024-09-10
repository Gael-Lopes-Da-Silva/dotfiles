#!/bin/bash

pacman -S --noconfirm nvidia nvidia-settings

modprobe nvidia_drm modeset=1
modprobe nvidia_drm fbdev=1

sed -i "s|MODULES=(btrfs)|MODULES=(btrfs nvidia nvidia_modeset nvidia_uvm nvidia_drm)|"

mkdir /etc/pacman.d/hooks/
echo -e "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\nTarget=linux\n[Action]\nDescription=Updating NVIDIA module in initcpio\nDepends=mkinitcpio\nWhen=PostTransaction\nNeedsTargets\nExec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'\n" >> /etc/pacman.d/hooks/nvidia.hook

nvidia-xconfig
