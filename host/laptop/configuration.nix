{ config, pkgs, ... }:

{
  networking.hostName = "laptop";

  # Import generated hardware config
  imports = [
    ./hardware-configuration.nix
  ];

  # Example: Intel graphics
  services.xserver.videoDrivers = [ "modesetting" ];

  powerManagement.enable = true;
}
