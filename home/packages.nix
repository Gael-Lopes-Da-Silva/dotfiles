{ pkgs, ... }:

let
  menu = pkgs.rustPlatform.buildRustPackage {
    pname = "menu";
    version = "0.1.0";

    src = ./menu;

    cargoLock.lockFile = ./menu/Cargo.lock;

    nativeBuildInputs = with pkgs; [
      pkg-config
      wrapGAppsHook4
    ];

    buildInputs = with pkgs; [
      gtk4
      libadwaita
    ];
  };
in
{
  home.packages = [
    menu
  ]
  ++ (with pkgs; [
    uv
    php
    bun
    clang
    rustup

    jq
    p7zip
    libsecret
    libnotify
    playerctl
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
    morphosis
    resources
    impression
    file-roller
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
  ]);
}
