#!/bin/sh

pacman -S --noconfirm lemurs
systemctl enable lemurs.service
