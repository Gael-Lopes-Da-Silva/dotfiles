{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };

      efi.canTouchEfiVariables = true;
    };

    initrd = {
      verbose = false;
    };

    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages_7_1;
    kernelModules = [ "v4l2loopback" ];
    kernelParams = [
      "quiet"
      "nowatchdog=1"
    ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
  };
}
