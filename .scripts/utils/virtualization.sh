#!/bin/bash

pacman -S --noconfirm virtualbox virtualbox-guest-iso virtualbox-host-modules-arch

modprobe virtio
modprobe vboxdrv
modprobe vboxnetadp
modprobe vboxnetflt

usermod -aG vboxusers gael
