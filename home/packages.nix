{ pkgs, ... }:

{
  home.packages = with pkgs; [
    uv
    php
    bun
    clang
    rustup

    jq
    p7zip
    libsecret
    libnotify
    pulseaudio
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite

    vial
    filezilla

    ghex
    pods
    lact
    coulr
    loupe
    kooha
    snoop
    pinta
    iotas
    packet
    papers
    baobab
    curtail
    cartero
    netpeek
    decibels
    snapshot
    nautilus
    showtime
    constrict
    parabolic
    morphosis
    resources
    impression
    pwvucontrol
    file-roller
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
    gnome-connections
    gnome-sound-recorder
    gnome-network-displays
  ];
}
