{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    # home.file.".config/zed/settings.json".source = ./settings.json;
    # home.file.".config/zed/keymap.json".source = ./keymap.json;
  };
}
