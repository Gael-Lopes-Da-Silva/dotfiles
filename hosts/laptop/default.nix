{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./wireguard.nix
  ];

  environment.systemPackages = with pkgs; [
    cursor-cli
  ];

  services = {
    tlp.enable = true;
  };

  home-manager.users.gael = {
    wayland.windowManager.niri.settings = {
      _children = [
        {
          output = {
            _args = [ "eDP-1" ];
            mode = "1920x1080@60";
            scale = 1.0;
            focus-at-startup = { };
            position._props = {
              x = 0;
              y = 0;
            };
          };
        }
      ];
    };
  };
}
