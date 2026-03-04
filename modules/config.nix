{ config, pkgs, ... }:

{
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
      options = "--delete-older-than 5d";
    };
  };

  # Boot
  boot = {
    initrd = {
      verbose = false;
    };

    consoleLogLevel = 0;

    kernelPackages = pkgs.linuxPackages_6_18;
    kernelModules = [ "v4l2loopback" ];
    kernelParams = [ "quiet" "udev.log_level=3" ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];
  };

  console.earlySetup = true;

  # Networking
  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  # Time
  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";

  # Security & Hardware
  security = {
    protectKernelImage = true;
    rtkit.enable = true;
  };

  # Virtualisation
  virtualisation = {
    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;

        daemon.settings = {
          dns = [ "1.1.1.1" "8.8.8.8" ];
        };
      };
    };

    virtualbox.host.enable = true;
  };

  # Environment
  environment = {
    variables = {
      EDITOR = "zeditor";
      VISUAL = "zeditor";
      GIT_EDITOR = "zeditor";
      GIT_PAGER = "less";
      TERMINAL = "alacritty";
      BROWSER = "firefox";
      PAGER = "less";

      LESS = "-R -F -X";
      LESSHISTFILE = "-";

      TERM = "xterm-256color";
      COLORTERM = "truecolor";

      VDPAU_DRIVER = "va_gl";
      MOZ_ENABLE_WAYLAND = "1";

      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_STATE_HOME = "$HOME/.local/state";

      LANG = "en_US.UTF-8";
      LC_ALL = "en_US.UTF-8";
      LC_CTYPE = "en_US.UTF-8";
      LC_TIME = "en_US.UTF-8";

      GTK_THEME = "Adwaita:dark";
      QT_QPA_PLATFORMTHEME = "qt5ct";
      QT_STYLE_OVERRIDE = "Fusion";
      QT_QUICK_CONTROLS_STYLE = "Fusion";
    };

    etc = {
      "xdg/gtk-2.0/gtkrc".text = "gtk-error-bell=0";
      "xdg/gtk-3.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=1
        gtk-error-bell=false
      '';
      "xdg/gtk-4.0/settings.ini".text = ''
        [Settings]
        gtk-application-prefer-dark-theme=1
        gtk-error-bell=false
      '';
    };
  };

  # User
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "vboxusers" ];
    shell = pkgs.nushell;
  };

  home-manager.users.gael = import ../home;
}
