#!/bin/sh

pacman -S --noconfirm ly
systemctl enable ly.service
