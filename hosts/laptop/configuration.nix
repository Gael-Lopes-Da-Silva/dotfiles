{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  services.xserver.videoDrivers = [ "modesetting" ];

  powerManagement.enable = true;
}
