{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./packages.nix
    ./audio.nix
  ];

  system.stateVersion = "25.11";
}
