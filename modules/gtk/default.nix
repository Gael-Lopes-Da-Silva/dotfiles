{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      gtk3
      gtk4
    ];

    gtk = {
      enable = true;
      theme = "Adwaita-dark";
      iconTheme = "Adwaita";
    };
  };
}
