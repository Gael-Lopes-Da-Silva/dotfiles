{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./bash
    ./clipboard
    ./dunst
    ./git
    ./gtk
    ./niri
    ./nvim
    ./qt
    ./scripts
    ./termscp
    ./udiskie
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
    fzf
    firefox
    ouch
    p7zip
    brightnessctl
    playerctl
    udiskie
    gvfs
    firejail
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
