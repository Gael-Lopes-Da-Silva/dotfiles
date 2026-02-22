#!/usr/bin/env bash

set -e

USER_NAME="$(whoami)"
DOTFILES_DIR="${HOME}/.dotfiles"
DOTFILES_REPO="https://github.com/Gael-Lopes-Da-Silva/dotfiles.git"

print() {
    printf "\e[34m%s\e[0m\n" "$*"
}

print "==> Starting installation..."

# -----------------
# Distro check
# -----------------
if [[ ! -f /etc/os-release ]]; then
    print "Unable to detect Linux distribution."
    exit 1
fi

. /etc/os-release

if [[ "$ID" != "arch" && "$ID_LIKE" != *"arch"* ]]; then
    print "This script requires an Arch-based distribution."
    print "Detected distro: $PRETTY_NAME"
    exit 1
fi

# -----------------
# System
# -----------------
print "==> Installing system configuration..."
{
    sudo pacman -S --noconfirm terminus-font > /dev/null

    echo "FONT=ter-132n" | sudo tee -a /etc/vconsole.conf

    sudo sed -i "s|#Color|Color|" /etc/pacman.conf
    sudo sed -i "s|#ParallelDownloads = 5|ParallelDownloads = 5|" /etc/pacman.conf
    sudo sed -i "s|#VerbosePkgLists|VerbosePkgLists|" /etc/pacman.conf
    sudo sed -i "s|#HookDir|HookDir|" /etc/pacman.conf
} > /dev/null

# -----------------
# Packages
# -----------------
print "==> Installing base packages..."
{
    sudo pacman -S --noconfirm \
      noto-fonts \
      noto-fonts-extra \
      noto-fonts-emoji \
      noto-fonts-cjk \
      nerd-fonts \
      git \
      stow \
      ouch \
      fzf \
      alacritty \
      neovim \
      firefox \
      zed \
      7zip
} > /dev/null

# -----------------
# Dotfiles
# -----------------
print "==> Setting up dotfiles..."

if [ ! -d "$DOTFILES_DIR" ]; then
    print "Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR" > /dev/null
else
    print "Dotfiles already exist, pulling latest changes..."
    git -C "$DOTFILES_DIR" pull > /dev/null
fi

{
    cd "$DOTFILES_DIR"
    stow home --adopt
    git restore .
} > /dev/null

# -----------------
# Desktop
# -----------------
print "==> Installing desktop packages..."
{
    sudo pacman -S --noconfirm \
      gtk3 \
      gtk4 \
      qt5-wayland \
      qt6-wayland \
      xdg-desktop-portal \
      xdg-desktop-portal-gtk \
      niri
} > /dev/null

# -----------------
# Utils
# -----------------
print "==> Installing system utils..."
{
    sudo pacman -S --noconfirm \
      accountsservice \
      power-profiles-daemon \
      cups-pk-helper \
      fprintd \
      wl-clipboard \
      wl-clip-persist \
      cliphist \
      xdg-user-dirs \
      xdg-user-dirs-gtk \
      firejail \
      wine \
      winetricks

    sudo systemctl enable --now power-profiles-daemon.service
    sudo systemctl enable --now fprintd.service

    xdg-user-dirs-update
    xdg-user-dirs-gtk-update
} > /dev/null

# -----------------
# Drivers
# -----------------
print "==> Installing drivers..."

if lspci | grep -i vga | grep -iq nvidia; then
  print "NVIDIA GPU detected"
  sudo pacman -S --noconfirm nvidia-dkms > /dev/null

  sudo sed -i '/^MODULES=/ s/)/ nvidia nvidia_modeset nvidia_uvm nvidia_drm)/' /etc/mkinitcpio.conf > /dev/null

  sudo mkinitcpio -P > /dev/null
elif lspci | grep -i vga | grep -iq intel; then
  print "Intel GPU detected"
  sudo pacman -S --noconfirm mesa vulkan-intel > /dev/null
fi

# -----------------
# Programming
# -----------------
print "==> Installing programming tools..."
{
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
} > /dev/null

# -----------------
# Auto mount
# -----------------
print "==> Setting up auto mounting..."
{
    sudo pacman -S --noconfirm \
      udiskie \
      gvfs \
      gvfs-mtp
} > /dev/null

print "==> Installation complete!"
