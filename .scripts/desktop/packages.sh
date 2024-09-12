#!/bin/bash

pacman -S --noconfirm stow neovim lazygit nushell feh kitty firefox chromium discord
pacman -S --noconfirm unzip unrar p7zip
pacman -S --noconfirm noto-fonts noto-fonts-extra noto-fonts-emoji noto-fonts-cjk ttf-cascadia-code
pacman -S --noconfirm papirus-icon-theme

chsh -s /usr/bin/nu

cd /home/gael/.dotfiles
stow .
