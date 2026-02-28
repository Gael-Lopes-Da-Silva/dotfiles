{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      xcursor-themes
      niri
    ];

    home.file.".config/niri/config.kdl".source = ./config.kdl;
  };

  programs.niri.enable = true;
}
