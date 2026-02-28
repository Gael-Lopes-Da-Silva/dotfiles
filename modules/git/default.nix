{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      git
    ];

    home.file.".gitconfig".source = ./.gitconfig;
  };
}
