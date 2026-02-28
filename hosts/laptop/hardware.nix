{ config, lib, pkgs, modulsPath, ... }:

{
  # boot = {
  #   initrd = {
  #     availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  #     kernelModules = [ ];
  #   };

  #   kernelModules = [ "kvm-intel" ];
  #   extraModulePackages = [ ];
  # };

  # fileSystems = {
  #   "/" = {
  #     device = "/dev/disk/by-uuid/a0287aac-a5ac-4693-8a64-35bd4e21651a";
  #     fsType = "ext4";
  #   };
  #   "/boot" = {
  #     device = "/dev/disk/by-uuid/977B-ECBD";
  #     fsType = "vfat";
  #     options = [ "fmask=0077" "dmask=0077" ];
  #   };
  # };

  # swapDevices = [
  #   { device = "/dev/disk/by-uuid/da8ea830-72db-4bf1-b694-756fd69b6d99"; }
  # ];

  # nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableReditributableFirmware;
}
