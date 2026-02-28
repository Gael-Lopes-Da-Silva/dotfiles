{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
    ./packages.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
    };
    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  boot = {
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };

  networking = {
    networkmanager.enable = true;
  };

  time = {
    timeZone = "Europe/Paris";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
  };

  services = {
    xserver.enable = false;
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  virtualisation = {
    docker.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];
  };

  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.bash;
  };

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.dates = "weekly";
    stateVersion = "25.11";
  };
}
