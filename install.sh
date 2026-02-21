#!/usr/bin/env bash

set -e

USER_NAME="$(whoami)"
DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/Gael-Lopes-Da-Silva/dotfiles.git"

echo "==> Starting installation..."

# -----------------
# Distro check
# -----------------
if [[ ! -f /etc/os-release ]]; then
  echo "Unable to detect Linux distribution."
  exit 1
fi

. /etc/os-release

if [[ "$ID" != "arch" && "$ID_LIKE" != *"arch"* ]]; then
  echo "This script requires an Arch-based distribution."
  echo "Detected distro: $PRETTY_NAME"
  exit 1
fi


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
  git \
  stow \
  ouch \
  alacritty \
  neovim \
  firefox \
  zed \
  7zip


# -----------------
# Dependencies
# -----------------
echo "==> Installing dependencies..."
sudo pacman -S --noconfirm \
  accountsservice \
  power-profiles-daemon \
  cups-pk-helper \
  fprintd

echo "=> Enabling related services..."
sudo systemctl enable --now power-profiles-daemon.service
sudo systemctl enable --now fprintd.service


# -----------------
# Dotfiles
# -----------------
echo "==> Setting up dotfiles..."

if [ ! -d "$DOTFILES_DIR" ]; then
  echo "Cloning dotfiles repository..."
  git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
else
  echo "Dotfiles already exist, pulling latest changes..."
  git -C "$DOTFILES_DIR" pull
fi

cd "$DOTFILES_DIR"
stow home --adopt
git restore .


# -----------------
# Desktop
# -----------------
echo "==> Installing desktop packages..."
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
  echo "=> NVIDIA GPU detected"
  sudo pacman -S --noconfirm nvidia-dkms

  sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf

  sudo mkinitcpio -P
elif lspci | grep -i vga | grep -iq intel; then
  echo "=> Intel GPU detected"
  sudo pacman -S --noconfirm mesa vulkan-intel
fi


# -----------------
# Programming
# -----------------
echo "==> Installing programming tools..."

sudo pacman -S --noconfirm \
  linux-headers \
  v4l2loopback-dkms \
  v4l2loopback-utils

sudo modprobe v4l2loopback

sudo pacman -S --noconfirm nodejs npm
sudo npm install -g bun

sudo pacman -S --noconfirm php composer

sudo pacman -S --noconfirm docker docker-compose
sudo usermod -aG docker "${USER_NAME}"
sudo systemctl enable --now docker.service


echo "==> Installation complete!"
