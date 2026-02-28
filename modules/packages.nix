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
    fzf
    firefox
    ouch
    p7zip
    cliphist
    wl-clip-persist
    wl-clipboard
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

  services = {
    wl-clip-persist = {
      enable = true;
      clipboardType = "regular";
    };
    cliphist = {
      enable = true;
      allowImages = true;
    };
    udiskie = {
      enable = true;
      tray = "auto";
      notify = true;
      automount = true;
    };
  };
}
