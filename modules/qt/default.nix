{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      qt5.qtwayland
      qt6.qtwayland
    ];

    qt = {
      enable = true;
      style = {
        name = "adwaita-dark";
      };
    };
  };
}
