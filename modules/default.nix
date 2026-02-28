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
    consoleLogLevel = 3;
  };

  console = {
    earlySetup = true;
    font = "${pkgs.terminus_font}/share/consolefonts/ter-122n.psf.gz";
    packages = with pkgs; [ terminus_font ];
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
    extraGroups = [ "wheel" "audio" "video" "docker" ];
    shell = pkgs.bash;
  };

  home-manager.users.gael = {
    home.stateVersion = "25.11";
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];

    dconf = {
      settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };
    };
  };

  system = {
    autoUpgrade.enable = true;
    autoUpgrade.dates = "weekly";
    stateVersion = "25.11";
  };
}
