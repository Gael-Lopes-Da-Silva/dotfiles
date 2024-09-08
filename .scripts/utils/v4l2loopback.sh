#!/bin/sh

pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils linux-headers
modprobe v4l2loopback
