{ config, lib, pkgs, modulsPath, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ ];
    };

    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/2b641924-f6ba-4e6c-ba11-f5f904d20bf4";
      fsType = "ext4";
    };
    "/mnt/disk" = {
      device = "/dev/disk/by-uuid/1bbc0128-f73b-4e7e-becd-c72933295304";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/E2BC-ED4B";
      fsType = "vfat";
      options = [ "fmask=0077" "dmask=0077" ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/de483c4f-08b7-421e-9d50-2831de4f1dd0"; }
  ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  hardware = {
    bluetooth.enable = true;
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    nvidia = {
      open = false;
      modesetting.enable = true;
      powerManagement.enable = false;
      powerManagement.finegrained = false;
      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.stable;
    };
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };

  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
}
