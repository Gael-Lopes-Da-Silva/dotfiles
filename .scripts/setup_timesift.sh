#!/bin/bash

cd ~

PARU=$(pacman -Qq paru)

if [[ ! $PARU = "paru" ]]; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/paru.git
    cd paru
    makepkg -si --noconfirm
    cd ..
    rm -rf paru
    echo "[+] Paru installed successfully"
else
    echo "[+] Paru already installed"
fi

sudo paru -S --noconfirm timeshift grub-btrfs timeshift-autosnap inotify-tools

echo "[+] Installed timeshift successfully"

sudo systemctl enable grub-btrfsd
sudo systemctl start grub-btrfsd

echo "[+] Timeshift enabled, setup manualy the wizard"
