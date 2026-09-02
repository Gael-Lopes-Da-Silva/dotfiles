{ pkgs, ... }:

{
  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    nixos.enable = false;

    man = {
      enable = true;

      cache = {
        enable = true;
        generateAtRuntime = true;
      };
    };
  };

  services.displayManager.ly = {
    enable = true;

    settings = {
      animation = "none";
      session_log = ".cache/ly/session.log";
      clock = null;
      bigclock = true;
      blank_password = true;
      blank_box = false;
      hide_borders = true;
      hide_key_hints = true;
      hide_version_string = true;
      load = true;
      save = true;
    };
  };

  environment = {
    variables = {
      EDITOR = "zeditor";
      VISUAL = "zeditor";
      TERMINAL = "kgx";
      BROWSER = "firefox";
      PAGER = "less";
      LESS = "-R --use-color";

      TERM = "xterm-256color";
      COLORTERM = "truecolor";

      VDPAU_DRIVER = "va_gl";
      MOZ_ENABLE_WAYLAND = "1";

      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_STATE_HOME = "$HOME/.local/state";

      GTK_IM_MODULE = "simple";
      QT_IM_MODULE = "simple";
      XMODIFIERS = "@im=simple";

      QT_QPA_PLATFORMTHEME = "adwaita";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QUICK_CONTROLS_STYLE = "adwaita-dark";

      GDK_SCALE = "1";
    };

    systemPackages = with pkgs; [
      man-pages
      man-pages-posix
    ];
  };

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    nerd-fonts.symbols-only
  ];

  programs = {
    nix-ld.enable = true;
    xwayland.enable = true;

    hyprland = {
      enable = true;
      withUWSM = false;
    };
  };

  system.stateVersion = "25.11";
}
