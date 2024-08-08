#!/bin/bash

function install_yay() {
    local YAY=$(pacman -Qq yay)

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
}

function install_v4l2loopback() {
    sudo pacman -S --needed --noconfirm base-devel linux-headers
    yay -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
    echo "[+] Installed v4l2loopback successfully"
    sudo modprobe v4l2loopback
    echo "[+] Enabled v4l2loopback successfully"
}

cd ~

install_yay
install_v4l2loopback
