{ config, pkgs, ... }:

{
  networking.hostName = "desktop";

  imports = [
    ./hardware-configuration.nix
  ];

  # Example: NVIDIA
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia.open = false;
  hardware.nvidia.modesetting.enable = true;
}
