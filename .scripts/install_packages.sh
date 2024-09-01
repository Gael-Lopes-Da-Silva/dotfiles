#!/bin/bash

cd ~

YAY=$(pacman -Qq yay)

if [[ ! $YAY = "yay" ]]; then
    sudo pacman -S --needed --noconfirm git base-devel
    git clone https://aur.archlinux.org/yay.git
    cd yay
    makepkg -si --noconfirm
    cd ~
    rm -rf yay
    echo "[+] Yay installed successfully"
else
    echo "[+] Yay already installed"
fi

sudo pacman -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
kitty neovim zsh ripgrep stow man-db man-pages firefox discord ttf-cascadia-code feh nnn \
btop

echo "[+] Installed all packages successfully"

sudo pacman -S --noconfirm i3-wm i3blocks i3lock xclip xorg-xsetroot maim xdotool acpi

echo "[+] Installed all i3 packages successfully"
