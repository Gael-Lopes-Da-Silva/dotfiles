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
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    pulseaudio

    bash-completion
    xwayland-satellite

    fzf
    tree
    firefox
    ouch
    p7zip
    cliphist
    wl-clipboard
    wl-clip-persist
    xdg-user-dirs
    xdg-user-dirs-gtk
    gnome-keyring
    brightnessctl
    playerctl
    udiskie
    gvfs
    firejail
    wine
    wine-wayland
    winetricks
    direnv

    python3
    bun
    php
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt
    docker-compose
  ];

  services.gvfs.enable = true;

  programs.firefox.enable = true;
  programs.xwayland.enable = true;
  programs.firejail.enable = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
