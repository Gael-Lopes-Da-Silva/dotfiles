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

sudo paru -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
kitty neovim zsh ripgrep stow man-db man-pages discord ttf-cascadia-code feh nnn \
btop zen-browser-bin

echo "[+] Installed all packages successfully"

sudo paru -S --noconfirm i3-wm i3blocks i3lock xclip xorg-xsetroot maim xdotool acpi

echo "[+] Installed all i3 packages successfully"
