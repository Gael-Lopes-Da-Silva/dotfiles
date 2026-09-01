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
      ./desktop/niri.nix
      ./desktop/hyprland.nix
      ./desktop/theme.nix
      ./desktop/clipboard.nix
      ./desktop/kanshi.nix
      ./desktop/mako.nix

      ./programs/apps.nix
      ./programs/bash.nix
      ./programs/git.nix
      ./programs/zed.nix

      ./scripts
      ./sounds
      ./packages.nix
    ];

    home = {
      stateVersion = "26.05";

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;

      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
        xdg-desktop-portal-hyprland
      ];

      config = {
        niri = {
          default = [
            "gnome"
            "gtk"
          ];
        };

        hyprland = {
          default = [
            "hyprland"
            "gnome"
            "gtk"
          ];
        };
      };
    };
  };
}
