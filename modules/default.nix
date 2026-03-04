{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./packages.nix
    ./audio.nix

    ./services
  ];

  system.stateVersion = "25.11";
}
