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

    warp
    ghex
    pods
    loupe
    kooha
    varia
    snoop
    pinta
    papers
    baobab
    alpaca
    turnon
    curtail
    dialect
    komikku
    foliate
    cartero
    bottles
    netpeek
    epiphany
    decibels
    eloquent
    snapshot
    nautilus
    showtime
    wildcard
    constrict
    collision
    parabolic
    morphosis
    speedtest
    inspector
    apostrophe
    eyedropper
    impression
    carburetor
    ascii-draw
    pwvucontrol
    livecaptions
    quick-lookup
    audio-sharing
    field-monitor

    gnome-maps
    gnome-boxes
    gnome-clocks
    gnome-weather
    gnome-decoder
    gnome-console
    gnome-calendar
    gnome-calculator
    gnome-characters
    gnome-text-editor
    gnome-connections
    gnome-system-monitor
    gnome-sound-recorder
    gnome-network-displays
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
