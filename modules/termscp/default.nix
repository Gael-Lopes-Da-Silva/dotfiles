{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      termscp
    ];

    home.file.".config/termscp/config.toml".source = ./config.toml;
  };
}
