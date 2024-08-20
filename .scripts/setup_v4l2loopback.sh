#!/bin/bash

cd ~

sudo pacman -S --needed --noconfirm base-devel linux-headers
sudo pacman -S --noconfirm v4l2loopback-dkms v4l2loopback-utils

echo "[+] Installed v4l2loopback successfully"

sudo modprobe v4l2loopback

echo "[+] Enabled v4l2loopback successfully"
