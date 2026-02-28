{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      cliphist
      wl-clip-persist
    ];

    services = {
      cliphist = {
        enable = true;
        allowImages = true;
        systemdTargets = "niri-session.target";
      };
      wl-clip-persist = {
        enable = true;
        clipboardType = "regular";
        systemdTargets = "niri-session.target";
      };
    };
  };
}
