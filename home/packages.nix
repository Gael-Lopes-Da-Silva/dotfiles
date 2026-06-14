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

    pods
    loupe
    kooha
    varia
    snoop
    papers
    baobab
    mousai
    alpaca
    turnon
    curtail
    dialect
    komikku
    foliate
    cartero
    decibels
    eloquent
    snapshot
    nautilus
    showtime
    wildcard
    constrict
    collision
    apostrophe
    eyedropper
    impression
    carburetor
    livecaptions
    quick-lookup
    audio-sharing

    gnome-maps
    gnome-boxes
    gnome-clocks
    gnome-decoder
    gnome-console
    gnome-calendar
    gnome-firmware
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
