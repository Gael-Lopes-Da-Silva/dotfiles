{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./dunst
    ./git
    ./gtk
    ./niri
    ./nushell
    ./qt
    ./scripts
    ./zed
  ];

  home = {
    stateVersion = "25.11";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };

  services = {
    home-manager.autoUpgrade = {
      enable = true;
      useFlake = true;
      flakeDir = "${config.users.users.gael.home}/.dotfiles";
      frequency = "weekly";
    };

    gnome-keyring.enable = true;
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
}
