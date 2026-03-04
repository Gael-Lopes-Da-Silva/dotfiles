{ config, pkgs, ... }:

{
  imports = [
    ./config.nix
    ./packages.nix
  ];

  system.stateVersion = "25.11";
}
