{ pkgs, ... }:

{
  home.packages = with pkgs; [
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
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
  };
}
