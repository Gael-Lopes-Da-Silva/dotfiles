{ ... }:

{
  imports = [
    ./hardware.nix
    ./wireguard.nix
  ];

  networking.hostName = "windows11";

  services = {
    tlp.enable = true;
  };

  home-manager.users.gael = {
    wayland.windowManager = {
      niri.settings._children = [
        {
          output = {
            _args = [ "eDP-1" ];
            mode = "1920x1080@60";
            scale = 1.0;
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
