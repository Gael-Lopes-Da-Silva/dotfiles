{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    p7zip
    libnotify
    pulseaudio
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite

    vial
    filezilla

    rtk
    opencode
    opencode-desktop

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
    turnon
    curtail
    dialect
    komikku
    foliate
    cartero
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
    fzf.enable = true;
  };
}
