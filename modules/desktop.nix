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

  services.displayManager.gdm = {
    enable = true;
  };

  services.desktopManager.gnome = {
    enable = true;
  };

  services.gnome.core-apps.enable = false;
  services.gnome.core-developer-tools.enable = false;
  services.gnome.games.enable = false;
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-user-docs
  ];

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

      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "adwaita";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QUICK_CONTROLS_STYLE = "adwaita-dark";
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
  };

  system.stateVersion = "25.11";
}
