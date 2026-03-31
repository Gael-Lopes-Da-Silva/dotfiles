{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./audio.nix
  ];

  nix = {
    optimise = {
      automatic = true;
      persistent = true;
      dates = "daily";
    };

    settings = {
      max-jobs = "auto";
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "gael"
      ];
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };
  };

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

    kernelPackages = pkgs.linuxPackages_6_18;
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

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  console.earlySetup = true;

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  time = {
    timeZone = "Europe/Paris";
  };

  i18n = {
    defaultLocale = "en_US.UTF-8";
    defaultCharset = "UTF-8";
  };

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;

    man = {
      enable = true;

      cache = {
        enable = true;
        generateAtRuntime = true;
      };
    };
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    polkit.enable = true;
  };

  virtualisation = {
    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;

        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
      };
    };

    virtualbox.host.enable = true;
  };

  systemd.oomd.enable = false;

  services = {
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;

    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    udev = {
      packages = with pkgs; [
        qmk
        qmk-udev-rules
        qmk_hid
        via
        vial
      ];
    };

    logind = {
      settings = {
        Login.HandlePowerKey = "ignore";
      };
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
        clock = null;
        bigclock = true;
        blank_password = true;
        blank_box = true;
        hide_borders = false;
        hide_key_hints = true;
        hide_version_string = true;
        load = true;
        save = true;
      };
    };
  };

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
      QT_QPA_PLATFORMTHEME = "qt6ct";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QUICK_CONTROLS_STYLE = "adwaita-dark";
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

  system.stateVersion = "25.11";
}
