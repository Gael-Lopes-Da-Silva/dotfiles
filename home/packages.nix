{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    yad
    p7zip
    wlrctl
    libnotify
    pulseaudio
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite

    vial
    filezilla

    loupe
    kooha
    varia
    papers
    baobab
    mousai
    alpaca
    turnon
    whatip
    curtail
    dialect
    komikku
    drawing
    foliate
    dissent
    cartero
    decibels
    eloquent
    snapshot
    nautilus
    showtime
    constrict
    collision
    apostrophe
    eyedropper
    impression

    gnome-maps
    gnome-boxes
    gnome-clocks
    gnome-decoder
    gnome-console
    gnome-calendar
    gnome-calculator
    gnome-characters
    gnome-text-editor
    gnome-connections
    gnome-system-monitor
    gnome-sound-recorder
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
