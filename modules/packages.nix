{ pkgs, ... }:

{
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
    vial
    ouch
    wine
    p7zip
    blender
    udiskie
    filezilla
    pulseaudio
    winetricks
    wine-wayland
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite
  ];

  services = {
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
  };

  programs = {
    niri.enable = true;
    hyprland.enable = true;
    firefox.enable = true;
    xwayland.enable = true;
    firejail.enable = true;
  };
}
