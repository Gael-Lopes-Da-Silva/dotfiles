{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
    ./configs.nix
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

  services.emptty = {
    enable = true;
    settings = {
      tty = "/dev/tty1";
    };
  };

  networking.networkmanager.enable = true;

  console.font = "ter-132n";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  services = {
    xserver.enable = false;
    printing.enable = true;
    pipewire = {
      enable = true;
      pulse.enable = true;
    };
  };

  virtualisation.docker.enable = true;

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.dates = "weekly";
    stateVersion = "25.11";
  };
}
