{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      alacritty
    ];

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
