{ config, pkgs, ... }:

{
  imports = [
    ./soundboard.nix

    ./audio_monitor.nix
    ./battery_monitor.nix
    ./brightness_monitor.nix
  ];
}
