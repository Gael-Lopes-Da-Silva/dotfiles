{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      udiskie
    ];

    services = {
      udiskie = {
        enable = true;
        tray = "auto";
        notify = true;
        automount = true;
      };
    };
  };
}
