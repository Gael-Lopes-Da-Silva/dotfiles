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
      ./desktop/clipboard.nix
      ./desktop/hyprland.nix
      ./desktop/mako.nix
      ./desktop/theme.nix

      ./programs/apps.nix
      ./programs/bash.nix
      ./programs/git.nix
      ./programs/zed.nix

      ./packages.nix

      ./scripts
      ./sounds
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
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gnome
      ];

      config = {
        niri = {
          default = [
            "gnome"
          ];
        };
        hyprland = {
          default = [
            "hyprland"
            "gnome"
          ];
        };
      };
    };
  };
}
