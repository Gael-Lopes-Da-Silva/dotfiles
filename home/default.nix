{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./dunst
    ./git
    ./gtk
    ./kanshi
    ./niri
    ./nushell
    ./qt
    ./scripts
    ./udiskie
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
