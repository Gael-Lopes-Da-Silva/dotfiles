{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.stateVersion = "25.11";
    home.sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };
}
