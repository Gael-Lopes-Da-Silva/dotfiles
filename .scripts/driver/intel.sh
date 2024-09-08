#!/bin/sh

pacman -S --noconfirm mesa vulkan-intel

modprobe i915 fastboot=1
