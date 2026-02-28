{ config, ... }:

{
  imports = [
    ./hardware.nix
  ];

  networking.hostName = "windows11";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services.libinput.enable = true;
}
