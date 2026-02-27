#!/usr/bin/env bash

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
    sudo pacman -S --noconfirm terminus-font

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
        ttf-nerd-fonts-symbols \
        ttf-nerd-fonts-symbols-common \
        ttf-nerd-fonts-symbols-mono \
        git \
        stow \
        ouch \
        fzf \
        alacritty \
        neovim \
        firefox \
        zed \
        7zip

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
    mkdir -p "${HOME}/.config"
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
        xdg-desktop-portal-gnome \
        xwayland-satellite
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

    sudo pacman -S --noconfirm termscp

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

# -----------------
# Dark mode
# -----------------
print "==> Applying dark mode..."
{
    mkdir -p ~/.config/gtk-3.0
    mkdir -p ~/.config/gtk-4.0

    printf '%s\n' \
    "[Settings]" \
    "gtk-application-prefer-dark-theme=1" \
    "gtk-theme-name=Adwaita-dark" \
    "gtk-icon-theme-name=Adwaita" \
    "gtk-cursor-theme-name=Adwaita" \
    >> ~/.config/gtk-3.0/settings.ini

    printf '%s\n' \
    "[Settings]" \
    "gtk-application-prefer-dark-theme=1" \
    "gtk-theme-name=Adwaita-dark" \
    "gtk-icon-theme-name=Adwaita" \
    "gtk-cursor-theme-name=Adwaita" \
    >> ~/.config/gtk-4.0/settings.ini

    mkdir -p ~/.config/xdg-desktop-portal

    printf '%s\n' \
    "[preferred]" \
    "default=gtk" \
    >> ~/.config/xdg-desktop-portal/portals.conf

    mkdir -p ~/.config/environment.d

    printf '%s\n' \
    "QT_QPA_PLATFORMTHEME=qt6ct" \
    "QT_STYLE_OVERRIDE=Fusion" \
    "QT_QUICK_CONTROLS_STYLE=Fusion" \
    >> ~/.config/environment.d/qt-dark.conf

    mkdir -p ~/.config/qt5ct
    mkdir -p ~/.config/qt6ct

    printf '%s\n' \
    "[Appearance]" \
    "style=Fusion" \
    "icon_theme=Adwaita" \
    >> ~/.config/qt5ct/qt5ct.conf

    printf '%s\n' \
    "[Appearance]" \
    "style=Fusion" \
    "icon_theme=Adwaita" \
    >> ~/.config/qt6ct/qt6ct.conf

    if command -v gsettings >/dev/null 2>&1; then
        gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' || true
        gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark' || true
    fi
} > /dev/null

# -----------------
# Display manager
# -----------------
print "==> Installing display manager..."
{
    sudo pacman -S --noconfirm emptty
    systemctl enable --now emptty.service
} > /dev/null

print "==> Installation complete!"
