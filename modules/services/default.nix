{ config, pkgs, ... }:

{
  imports = [
    ./soundboard.nix

    ./audio_monitor.nix
  ];
}
