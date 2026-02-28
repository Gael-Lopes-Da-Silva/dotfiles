{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./bash
    ./dunst
    ./git
    ./gtk
    ./niri
    ./nvim
    ./scripts
    ./termscp
    ./zed
  ];

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    qt5.qtwayland
    qt6.qtwayland
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xwayland-satellite

    fzf
    firefox
    ouch
    p7zip
    wl-clipboard
    brightnessctl
    playerctl
    udiskie
    gvfs
    wine
    winetricks

    python3
    bun
    php
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    docker-compose
    bash-completion
  ];
}
