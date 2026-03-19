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
    ouch
    wine
    p7zip
    udiskie
    pulseaudio
    winetricks
    wine-wayland
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite

    vial
    blender
    filezilla
  ];

  services = {
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
  };

  programs = {
    niri.enable = true;
    firefox.enable = true;
    xwayland.enable = true;
    firejail.enable = true;
  };
}
