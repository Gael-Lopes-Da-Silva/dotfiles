{ config, pkgs, ... }:

{
  users.users.gael = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" ];
    shell = pkgs.bash;
  };

  home-manager.users.gael = {
    home.stateVersion = "24.11";

    home.packages = with pkgs; [
      # bun
      # php
      # composer
      # rustup
      # python3
    ];
  };
}
