{ config, pkgs, ... }:

{
  imports = [
    ./packages
  ];

  # Nix
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      auto-optimise-store = true;
      trusted-users = [ "root" "gael" ];
      cores = 0;
      max-jobs = "auto";
    };

    gc = {
      automatic = true;
      dates = "daily";
      options = "--delete-older-than 10d";
    };
  };

  # Boot
  boot = {
    consoleLogLevel = 2;

    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };

  console.earlySetup = true;

  # Networking & Time
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # Security & Hardware
  security = {
    protectKernelImage = true;
    rtkit.enable = true;
  };

  hardware.bluetooth.enable = true;

  # Services
  services = {
    xserver.enable = false;
    printing.enable = true;
    blueman.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

    openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    displayManager.ly = {
      enable = true;
      settings = {
        animation = "colormix";
        session_log = ".cache/ly/session.log";
        clock = "%d-%m-%Y %H:%M:%S";
        bigclock = true;
        blank_password = true;
        blank_box = true;
        hide_borders = false;
        hide_key_hints = true;
        load = true;
        save = true;
      };
    };
  };

  # Virtualisation
  virtualisation.docker.enable = true;

  # XDG Portals
  xdg.portal = {
    enable = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config.common.default = [ "gtk" "gnome" ];
  };

  # Users
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "docker" ];
    shell = pkgs.nushell;
  };

  # Home Manager
  home-manager.users.gael = {
    home = {
      stateVersion = "25.11";
      sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.cargo/bin"
      ];
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme =
      "prefer-dark";
  };

  # System
  system = {
    autoUpgrade = {
      enable = true;
      dates = "weekly";
    };

    stateVersion = "25.11";
  };
}
