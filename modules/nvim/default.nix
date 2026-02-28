{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      neovim
    ];

    home.file.".config/nvim/init.lua".source = ./init.lua;
    home.file.".config/niri/lua" = {
      source = ./lua;
      recursive = true;
    };
  };
}
