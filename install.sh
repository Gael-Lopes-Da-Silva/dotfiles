#!/usr/bin/env bash

set -e

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
    mkdir "~/.config"
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
      niri \
      gtk3 \
      gtk4 \
      qt5-wayland \
      qt6-wayland \
      xdg-desktop-portal \
      xdg-desktop-portal-gtk \
      xdg-desktop-portal-gnome
} > /dev/null

# -----------------
# Utils
# -----------------
print "==> Installing system utils..."
{
    sudo pacman -S --noconfirm \
      accountsservice \
      cups-pk-helper \
      wl-clipboard \
      wl-clip-persist \
      cliphist \
      brightnessctl \
      playerctl \
      xdg-user-dirs \
      xdg-user-dirs-gtk \
      gnome-keyring \
      firejail \
      wine \
      winetricks \
      dunst \
      udiskie \
      gvfs \
      gvfs-mtp

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

    sudo pacman -S --noconfirm python
    sudo pacman -S --noconfirm bun
    sudo pacman -S --noconfirm php composer
    sudo pacman -S --noconfirm rustup
    rustup default stable
    rustup component add rust-src
    rustup component add rust-analyzer
    rustup component add clippy
    rustup component add rustfmt

    sudo pacman -S --noconfirm docker docker-compose
    sudo usermod -aG docker "$(whoami)"
    sudo systemctl enable --now docker.service
} > /dev/null

print "==> Installation complete!"
