#!/bin/bash

set -ex

USER="gael"
sudo -v

# Terminal
sudo pacman -S --noconfirm terminus-font
setfont ter-132n
echo -e "FONT=ter-132n" | sudo tee -a /etc/vconsole.conf

# Pacman
sudo sed -i "s|#Color|Color|" /etc/pacman.conf
sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf

# Paru
git clone https://aur.archlinux.org/paru.git
cd paru
makepkg -si --noconfirm
cd ..
rm -rf ./paru/

# Packages
sudo paru -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code ouch stow bash-completion chromium neovim ripgrep udiskie dunst feh xdg-desktop-portal xdg-desktop-portal-gtk ttf-liberation papirus-icon-theme linux-headers

# Stow
cd /home/$USER/.dotfiles/
stow home --adopt
git restore .

# Desktop
sudo paru -S --noconfirm xorg xorg-xinit xclip maim upower brightnessctl network-manager-applet
cd /home/$USER/.dotfiles/home/.config/suckless/dwm
sudo make clean install
cd /home/$USER/.dotfiles/home/.config/suckless/dwmblocks
sudo make clean install
cd /home/$USER/.dotfiles/home/.config/suckless/dmenu
sudo make clean install

# Dark Mode
dconf write /org/gnome/desktop/interface/color-scheme \'prefer-dark\'

# Gpu Drivers
if lspci | grep -i vga | grep -iq nvidia; then
    sudo paru -S --noconfirm nvidia
    sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf
    sudo mkinitcpio -P
    sudo nvidia-xconfig
    sudo mkdir /etc/pacman.d/hooks
    echo -e "[Trigger]\nOperation=Install\nOperation=Upgrade\nOperation=Remove\nType=Package\nTarget=nvidia\nTarget=nvidia-open\nTarget=nvidia-lts\nTarget=linux\n\n[Action]\nDescription=Updating NVIDIA module in initcpio\nDepends=mkinitcpio\nWhen=PostTransaction\nNeedsTargets\nExec=/bin/sh -c 'while read -r trg; do case \$trg in linux*) exit 0; esac; done; /usr/bin/mkinitcpio -P'" | sudo tee /etc/pacman.d/hooks/nvidia.hook > /dev/null
fi

if lspci | grep -i vga | grep -iq intel; then
    sudo paru -S --noconfirm mesa vulkan-intel
fi

# Loopback
sudo paru -S --noconfirm v4l2loopback-dkms v4l2loopback-utils
sudo modprobe v4l2loopback

# Docker
sudo paru -S --noconfirm docker
sudo usermod -aG docker $USER
sudo systemctl enable docker.service

# Virtualization
sudo paru -S --noconfirm libvirt dnsmasq qemu-full virt-manager virt-viewer
sudo usermod -aG libvirt $USER
sudo systemctl enable libvirtd.service

# Soundboard
systemctl --user enable soundboard.service
systemctl --user start soundboard.service
