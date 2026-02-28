{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.stateVersion = "25.11";

  #   home.file = {
  #     ".gitconfig" = {
  #       source = ../home/.gitconfig;
  #       target = ".";
  #     };
  #     ".local/bin" = {
  #       source = ../home/.scripts;
  #       target = ".local/bin";
  #     };
  #     ".config/alacritty" = {
  #       source = ../home/.config/alacritty;
  #       target = ".config/alacritty";
  #       recursive = true;
  #     };
  #     ".config/dunst" = {
  #       source = ../home/.config/dunst;
  #       target = ".config/dunst";
  #       recursive = true;
  #     };
  #     ".config/niri" = {
  #       source = ../home/.config/niri;
  #       target = ".config/niri";
  #       recursive = true;
  #     };
  #     ".config/nvim" = {
  #       source = ../home/.config/nvim;
  #       target = ".config/nvim";
  #       recursive = true;
  #     };
  #     ".config/termscp" = {
  #       source = ../home/.config/termscp;
  #       target = ".config/termscp";
  #       recursive = true;
  #     };
  #     ".config/zed" = {
  #       source = ../home/.config/zed;
  #       target = ".config/zed";
  #       recursive = true;
  #     };
  #   };

  #   home.sessionPath = [
  #     "$HOME/.local/bin"
  #     "$HOME/.cargo/bin"
  #   ];

  #   home.sessionVariables = {
  #     EDITOR = "nvim";
  #     VISUAL = "nvim";
  #     GIT_EDITOR = "nvim";
  #     GIT_PAGER = "less";
  #     TERMINAL = "alacritty";
  #     BROWSER = "firefox";
  #     PAGER = "less";

  #     LESS = "-R -F -X";
  #     LESSHISTFILE = "-";

  #     TERM = "xterm-256color";
  #     COLORTERM = "truecolor";

  #     VDPAU_DRIVER = "va_gl";
  #     MOZ_ENABLE_WAYLAND = "1";

  #     XDG_CONFIG_HOME = "$HOME/.config";
  #     XDG_DATA_HOME = "$HOME/.local/share";
  #     XDG_CACHE_HOME = "$HOME/.cache";
  #     XDG_STATE_HOME = "$HOME/.local/state";

  #     LANG = "en_US.UTF-8";
  #     LC_ALL = "en_US.UTF-8";
  #     LC_CTYPE = "en_US.UTF-8";
  #     LC_TIME = "en_US.UTF-8";

  #     GTK_THEME = "Adwaita:dark";
  #     QT_QPA_PLATFORMTHEME = "qt5ct";
  #     QT_STYLE_OVERRIDE = "Fusion";
  #     QT_QUICK_CONTROLS_STYLE = "Fusion";
  #   };
  };
}
