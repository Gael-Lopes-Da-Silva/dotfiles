{ pkgs, ... }:

{
  home.packages = with pkgs; [
    p7zip
    p7zip-rar

    udiskie
    pulseaudio
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
