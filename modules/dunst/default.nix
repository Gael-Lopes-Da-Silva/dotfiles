{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      dunst
    ];

    home.file.".config/alacritty/dunstrc".source = ./dunstrc;
  };
}
