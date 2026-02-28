{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./bash
    ./dunst
    ./git
    ./gtk
    ./niri
    ./qt
    ./scripts
    ./termscp
    ./zed
  ];

  fonts.packages = with pkgs; [
    # Noto families
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    # Symbols
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [

    # Audio
    pulseaudio
    playerctl

    # Wayland / Desktop
    xwayland-satellite
    wl-clipboard
    wl-clip-persist
    cliphist
    brightnessctl

    # Core Utilities
    tree
    p7zip
    ouch
    xdg-user-dirs
    xdg-user-dirs-gtk

    # Desktop Integration
    gnome-keyring
    gvfs
    udiskie

    # Applications
    firefox

    # Sandboxing
    firejail
    wine
    wine-wayland
    winetricks

    # Development
    direnv
    python3
    bun
    php

    # Rust
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    # Containers
    docker-compose
  ];

  services.gvfs.enable = true;

  programs = {
    firefox.enable = true;
    xwayland.enable = true;
    firejail.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
