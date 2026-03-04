{ config, pkgs, ... }:

{
  imports = [
    # ./audio_monitor.nix
    # ./battery_monitor.nix
    # ./brightness_monitor.nix

    ./soundboard.nix
  ];
}
