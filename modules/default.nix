{ config, pkgs, ... }:

{
  imports = [
    ./user.nix
    ./configs.nix
    ./packages.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  system.stateVersion = "24.11";
}
