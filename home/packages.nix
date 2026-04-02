{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    yad
    p7zip
    dotool
    udiskie
    libnotify
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
    polkit-gnome.enable = true;
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
  };
}
