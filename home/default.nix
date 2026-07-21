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
      ./configs/niri
      ./configs/scripts
      ./configs/sounds

      ./configs/bash.nix
      ./configs/clipboard.nix
      ./configs/git.nix
      ./configs/gtk.nix
      ./configs/kanshi.nix
      ./configs/mako.nix
      ./configs/qt.nix
      ./configs/zed.nix

      ./packages.nix
    ];

    home = {
      stateVersion = "26.05";

      sessionPath = [
        "$HOME/.local/bin"
      ];

      pointerCursor = {
        enable = true;
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
