{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "modesetting" ];

  powerManagement.enable = true;
}
