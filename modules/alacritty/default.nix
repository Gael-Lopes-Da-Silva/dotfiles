{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      alacritty
    ];

    home.programs.alacritty = {
      enable = true;

      settings = {
        window = {
          padding = { x = 10; y = 10; };
          dynamicPadding = true;
          opacity = 0.8;
        };

        font = {
          size = 18.0;
        };

        cursor = {
          style = { shape = "Block"; blinking = "Off"; };
          unfocusedHollow = true;
            thickness = 0.2;
        };

        mouse = {
          hideWhenTyping = true;
        };

        keyboard = {
          bindings = [
            { key = "Back"; mods = "Control"; chars = "\u0017"; }
              { key = "Enter"; mods = "Control|Shift"; chars = "\u0017"; }
          ];
        };
      };
    };
  };
}
