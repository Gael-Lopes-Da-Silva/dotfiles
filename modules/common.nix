{ config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  time.timeZone = "Europe/Paris";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.enable = false; # using Wayland

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    git
    stow
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
  ];

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerd-fonts.symbols-only
  ];

  # Docker
  virtualisation.docker.enable = true;

  # Niri (Wayland compositor)
  programs.niri.enable = true;

  # Display manager
  services.displayManager.greetd.enable = true;

  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.zsh;
  };

  home-manager.users.gael = {
    home.stateVersion = "24.11";

    home.packages = with pkgs; [
      bun
      php
      composer
      rustup
      python3
    ];
  };

  system.stateVersion = "24.11";
}
