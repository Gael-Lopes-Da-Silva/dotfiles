{ config, pkgs, ... }:

{
  imports = [
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

  security.rtkit.enable = true;

  services = {
    xserver.enable = false;
    printing.enable = true;
    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      wireplumber.enable = true;
    };
    displayManager = {
      ly = {
        enable = true;
        settings = {};
      };
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
    config = {
      common = {
        default = [ "gtk" "gnome" ];
      };
    };
  };

  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.bash;
  };

  home-manager.users.gael = {
    home.stateVersion = "25.11";
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.dates = "weekly";
    stateVersion = "25.11";
  };
}
