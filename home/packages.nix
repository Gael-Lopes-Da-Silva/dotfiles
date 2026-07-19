{ pkgs, ... }:

{
  home.packages = with pkgs; [
    jq
    rtk
    p7zip
    libnotify
    pulseaudio
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite

    vial
    filezilla

    pi-coding-agent

    warp
    ghex
    pods
    lact
    coulr
    loupe
    kooha
    varia
    snoop
    pinta
    papers
    baobab
    curtail
    dialect
    cartero
    netpeek
    epiphany
    decibels
    snapshot
    nautilus
    showtime
    wildcard
    constrict
    collision
    parabolic
    morphosis
    inspector
    resources
    apostrophe
    impression
    pwvucontrol
    livecaptions
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
    gnome-sound-recorder
    gnome-network-displays
  ];

  services = {
    polkit-gnome.enable = true;
    gnome-keyring.enable = true;
    ssh-agent.enable = true;
    ollama.enable = true;
  };

  programs = {
    home-manager.enable = true;
    firefox.enable = true;
    fzf.enable = true;
  };
}
