{ config, pkgs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
}
