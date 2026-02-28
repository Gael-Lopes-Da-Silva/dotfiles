{ config, pkgs, ... }:

{
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
}
