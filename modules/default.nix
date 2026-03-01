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
      options = "--delete-older-than 5d";
    };
  };

  # Boot
  boot = {
    consoleLogLevel = 0;

    kernelPackages = pkgs.linuxPackages_6_18;
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
  virtualisation = {
    docker.enable = true;
    virtualbox.host.enable = true;
  };

  # Environment
  environment.variables = {
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

  # Users
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "audio" "video" "docker" "vboxusers" ];
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

    services.home-manager.autoUpgrade = {
      enable = true;
      useFlake = true;
      flakeDir = "${config.users.users.gael.home}/.dotfiles";
      frequency = "weekly";
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];

      config.common.default = [ "gtk" "gnome" ];
    };

    dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
  };

  # System
  system = {
    stateVersion = "25.11";
  };
}
