{ pkgs, ... }:

{
  imports = [
    ./alacritty
    ./bash
    ./clipboard
    ./dunst
    ./git
    ./gtk
    ./kanshi
    ./niri
    ./ollama
    ./qt
    ./scripts
    ./zed

    ./packages.nix
  ];

  home = {
    stateVersion = "26.05";

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];

    pointerCursor = {
      hyprcursor.enable = true;
      gtk.enable = true;
      package = pkgs.adwaita-icon-theme;
      name = "Adwaita";
      size = 24;
    };
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config.common.default = [
      "gtk"
      "gnome"
    ];
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/desktop/wm/preferences".button-layout = "";
  };
}
