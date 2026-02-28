{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      qt5.qtwayland
      qt6.qtwayland
    ];
  };
}
