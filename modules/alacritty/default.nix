{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      alacritty
    ];

    programs.alacritty = {
      enable = true;
      settings = {};
    };

    home.file.".config/alacritty/alacritty.toml".source = ./alacritty.toml;
  };
}
