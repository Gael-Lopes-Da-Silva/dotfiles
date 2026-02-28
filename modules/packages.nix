{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    fzf
    neovim
    firefox
    alacritty
    zed-editor
    ouch
    p7zip
    wl-clipboard
    brightnessctl
    playerctl
    dunst
    udiskie
    gvfs
    wine
    winetricks
    termscp

    python3
    bun
    php
    composer
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    docker-compose
    bash-completion
  ];
}
