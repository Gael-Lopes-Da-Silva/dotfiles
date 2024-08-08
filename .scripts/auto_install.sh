function install_yay() {
    local YAY=$(pacman -Qq yay)

    if [[ ! $YAY = "yay" ]]; then
        pacman -S --needed --noconfirm git base-devel
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

function install_packages() {
    yay -S --noconfirm noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra \
    kitty neovim zsh ripgrep stow man-db man-pages firefox discord
    echo "[+] Installed all packages successfully"
}

function install_i3packages() {
    yay -S --noconfirm i3-wm i3blocks i3lock xclip xorg-xsetroot \
    v4l2loopback-dkms v4l2loopback-utils
    echo "[+] Installed all i3 packages successfully"
}

cd ~

install_yay
install_packages
install_i3packages
