{ pkgs, ... }:

{
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [
      "disk"
      "input"
      "wheel"
      "audio"
      "video"
      "uinput"
      "vboxusers"
    ];
  };

  home-manager.users.gael = {
    imports = [
      ./bash
      ./clipboard
      ./git
      ./gtk
      ./kanshi
      ./mako
      ./niri
      ./qt
      ./scripts
      ./sounds
      ./zed

      ./packages.nix
    ];

    home = {
      stateVersion = "26.05";

      sessionPath = [
        "$HOME/.local/bin"
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
        xdg-desktop-portal-gnome
      ];

      config.common.default = [
        "gnome"
      ];
    };

    dconf.settings = {
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/desktop/wm/preferences".button-layout = ":close";
    };
  };
}
