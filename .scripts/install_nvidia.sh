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

function install_nvidia_drivers() {
    sudo pacman -S --needed --noconfirm base-devel linux-headers
    yay -S --noconfirm nvidia nvidia-utils nvidia-settings
    echo "[+] Nvidia drivers installed successfully"
    echo ""
    echo "[?] To enable DRM kernel mode, in /etc/default/grub"
    echo "[?] find GRUB_CMDLINE_LINUX_DEFAULT and add nvidia-drm.modeset=1 nvidia_drm.fbdev=1"
    echo "[?] After that, run: sudo grub-mkconfig -o /boot/grub/grub.cfg"
    echo ""
    echo "[?] To enable early loading, in /etc/mkinitcpio.conf"
    echo "[?] in MODULES add nvidia nvidia_modeset nvidia_uvm nvidia_drm"
    echo "[?] in HOOKS remove kms"
    echo "[?] After that, run: sudo mkinitcpio -P"
}

cd ~

install_yay
install_nvidia_drivers
