{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      alacritty
    ];

    programs.alacritty = {
      enable = true;
      settings = {
        window = {
          padding = {
            x = 10;
            y = 10;
          };
          dynamic_padding = true;
          opacity = 0.8;
        };

        font = {
          size = 18.0;
          normal = {
            family = "Monospace";
            style = "Regular";
          };
        };

        cursor = {
          style = {
            shape = "Block";
            blinking = "Off";
          };
          unfocused_hollow = true;
          thickness = 0.2;
        };

        mouse = {
          hide_when_typing = true;
        };

        keyboard = {
          bindings = [
            {
              key = "Back";
              mods = "Control";
              chars = "\\u0017";
            }
            {
              key = "Enter";
              mods = "Control|Shift";
              chars = "\\u0017";
            }
          ];
        };
      };
    };
  };
}
