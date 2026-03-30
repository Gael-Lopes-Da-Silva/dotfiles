{ pkgs, ... }:

{
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [
      "disk"
      "wheel"
      "audio"
      "video"
      "vboxusers"
    ];
  };

  home-manager.users.gael = {
    imports = [
      ./alacritty
      ./bash
      ./clipboard
      ./git
      ./gtk
      ./kanshi
      ./mako
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
  };
}
