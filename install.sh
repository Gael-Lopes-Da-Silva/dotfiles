#!/usr/bin/env bash

set -e

USER_NAME="$(whoami)"

echo "==> Starting installation..."

# -----------------
# System
# -----------------
echo "==> Installing system configuration..."
sudo pacman -S --noconfirm terminus-font

echo "FONT=ter-132n" | sudo tee -a /etc/vconsole.conf

sudo sed -i "s|#Color|Color|" /etc/pacman.conf
sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf


# -----------------
# Packages
# -----------------
echo "==> Installing base packages..."
sudo pacman -S --noconfirm \
  noto-fonts \
  noto-fonts-extra \
  noto-fonts-emoji \
  noto-fonts-cjk \
  alacritty \
  neovim \
  firefox \
  zed \
  stow \
  ouch \
  ripgrep \
  7zip \
  bash-completion


# -----------------
# Desktop
# -----------------
echo "==> Setting up desktop..."
cd "${HOME}/.dotfiles/"
stow home --adopt
git restore .

sudo pacman -S --noconfirm \
  gtk3 \
  gtk4 \
  qt5-wayland \
  qt6-wayland \
  xdg-desktop-portal \
  xdg-desktop-portal-gtk \
  niri


# -----------------
# Drivers
# -----------------
echo "==> Installing drivers..."

if lspci | grep -i vga | grep -iq nvidia; then
  echo "NVIDIA GPU detected"
  sudo pacman -S --noconfirm nvidia-dkms dkms libvdpau-va-gl

  sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' \
    /etc/mkinitcpio.conf

  sudo mkinitcpio -P
elif lspci | grep -i vga | grep -iq intel; then
  echo "Intel GPU detected"
  sudo pacman -S --noconfirm mesa vulkan-intel
fi


# -----------------
# Programming
# -----------------
echo "==> Installing programming tools..."

sudo pacman -S --noconfirm \
  v4l2loopback-dkms \
  v4l2loopback-utils

sudo modprobe v4l2loopback

sudo pacman -S --noconfirm nodejs npm
sudo npm -g install bun

sudo pacman -S --noconfirm php composer

sudo pacman -S --noconfirm docker docker-compose
sudo usermod -aG docker "${USER_NAME}"
sudo systemctl enable docker.service


echo "==> Installation complete!"