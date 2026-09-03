{ ... }:

{
  wayland.windowManager.niri = {
    enable = true;

    settings = {
      spawn-sh-at-startup = "bash ~/.local/bin/autostart.sh";

      prefer-no-csd = { };
      screenshot-path = null;

      input = {
        mod-key = "Super";
        mod-key-nested = "Alt";

        keyboard.xkb = {
          layout = "us";
          variant = "intl";
        };

        touchpad = {
          tap = { };
          natural-scroll = { };
        };

        focus-follows-mouse._props = {
          max-scroll-amount = "0%";
        };
      };

      layout = {
        gaps = 10;
        background-color = "#303030";
        empty-workspace-above-first = { };
        center-focused-column = "never";

        preset-column-widths._children = [
          { proportion = 0.5; }
          { proportion = 1.0; }
        ];

        preset-window-heights._children = [
          { proportion = 0.5; }
          { proportion = 1.0; }
        ];

        default-column-width._children = [
          { proportion = 1.0; }
        ];

        focus-ring.off = { };

        border = {
          on = { };
          width = 1;
          active-color = "#404040";
          inactive-color = "#303030";
        };

        tab-indicator = {
          off = { };
        };

        shadow = {
          on = { };
          softness = 4;
          spread = 2;
          color = "#00000070";
          inactive-color = "#00000054";
          offset._props = {
            x = 0;
            y = 2;
          };
        };

        struts = {
          left = 5;
          right = 5;
          top = 5;
          bottom = 5;
        };
      };

      overview = {
        zoom = 0.45;

        workspace-shadow = {
          on = { };
          softness = 6;
          spread = 4;
          color = "#00000070";
          offset._props = {
            x = 0;
            y = 4;
          };
        };
      };

      cursor = {
        xcursor-theme = "Bibata-Modern-Classic";
        xcursor-size = 22;
      };

      clipboard = {
        disable-primary = { };
      };

      gestures = {
        hot-corners.off = { };
      };

      hotkey-overlay = {
        skip-at-startup = { };
      };

      recent-windows = {
        off = { };
      };

      _children = [
        {
          window-rule._children = [
            { geometry-corner-radius = 12; }
            { clip-to-geometry = true; }
            { open-maximized-to-edges = false; }
            { open-maximized = false; }
            { open-fullscreen = false; }
          ];
        }
        {
          window-rule._children = [
            {
              match._props = {
                app-id = "steam";
                title = "^notificationtoasts";
              };
            }
            { geometry-corner-radius = 12; }
            { open-focused = false; }
            { open-floating = true; }
            {
              default-floating-position._props = {
                x = 5;
                y = 5;
                relative-to = "bottom-right";
              };
            }
          ];
        }
      ];

      binds = {
        "Mod+Return" = {
          _props.repeat = false;
          spawn = [ "kgx" ];
        };
        "Mod+BackSpace" = {
          _props.repeat = false;
          spawn = [ "firefox" ];
        };

        "Mod+P" = {
          _props.repeat = false;
          spawn-sh = [ "menu --applications" ];
        };
        "Mod+Q" = {
          _props.repeat = false;
          spawn-sh = [ "menu --power" ];
        };

        "Mod+N" = {
          _props.repeat = false;
          spawn-sh = [ "bash ~/.local/bin/datetime_notify.sh" ];
        };
        "Mod+B" = {
          _props.repeat = false;
          spawn-sh = [ "bash ~/.local/bin/battery_notify.sh" ];
        };
        "Mod+W" = {
          _props.repeat = false;
          spawn-sh = [ "bash ~/.local/bin/workspace_notify.sh" ];
        };

        "Mod+Ctrl+C" = {
          _props.repeat = false;
          spawn-sh = [ "bash ~/.local/bin/kill_process.sh" ];
        };
        "Mod+Ctrl+F" = {
          _props.repeat = false;
          spawn-sh = [ "bash ~/.local/bin/freeze_process.sh" ];
        };

        "XF86AudioRaiseVolume".spawn-sh = [
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
        ];
        "XF86AudioLowerVolume".spawn-sh = [
          "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
        ];
        "XF86AudioMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];
        "XF86AudioMicMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ];

        "XF86AudioPlay".spawn-sh = [ "playerctl play-pause" ];
        "XF86AudioStop".spawn-sh = [ "playerctl stop" ];
        "XF86AudioPrev".spawn-sh = [ "playerctl previous" ];
        "XF86AudioNext".spawn-sh = [ "playerctl next" ];

        "XF86MonBrightnessUp".spawn-sh = [ "brightnessctl --class=backlight set +10%" ];
        "XF86MonBrightnessDown".spawn-sh = [ "brightnessctl --class=backlight set 10%-" ];

        "Mod+Left".focus-column-left = { };
        "Mod+Down".focus-window-down = { };
        "Mod+Up".focus-window-up = { };
        "Mod+Right".focus-column-right = { };
        "Mod+H".focus-column-left = { };
        "Mod+J".focus-window-down = { };
        "Mod+K".focus-window-up = { };
        "Mod+L".focus-column-right = { };

        "Mod+Ctrl+Left".move-column-left = { };
        "Mod+Ctrl+Down".move-window-down = { };
        "Mod+Ctrl+Up".move-window-up = { };
        "Mod+Ctrl+Right".move-column-right = { };
        "Mod+Ctrl+H".move-column-left = { };
        "Mod+Ctrl+J".move-window-down = { };
        "Mod+Ctrl+K".move-window-up = { };
        "Mod+Ctrl+L".move-column-right = { };

        "Mod+Home".focus-column-first = { };
        "Mod+End".focus-column-last = { };
        "Mod+Ctrl+Home".move-column-to-first = { };
        "Mod+Ctrl+End".move-column-to-last = { };

        "Mod+Shift+Left".focus-monitor-left = { };
        "Mod+Shift+Down".focus-monitor-down = { };
        "Mod+Shift+Up".focus-monitor-up = { };
        "Mod+Shift+Right".focus-monitor-right = { };
        "Mod+Shift+H".focus-monitor-left = { };
        "Mod+Shift+J".focus-monitor-down = { };
        "Mod+Shift+K".focus-monitor-up = { };
        "Mod+Shift+L".focus-monitor-right = { };

        "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
        "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
        "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
        "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
        "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

        "Mod+Page_Down".focus-workspace-down = { };
        "Mod+Page_Up".focus-workspace-up = { };
        "Mod+U".focus-workspace-down = { };
        "Mod+I".focus-workspace-up = { };
        "Mod+Shift+Page_Down".move-workspace-down = { };
        "Mod+Shift+Page_Up".move-workspace-up = { };
        "Mod+Shift+U".move-workspace-down = { };
        "Mod+Shift+I".move-workspace-up = { };
        "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
        "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };
        "Mod+Ctrl+U".move-column-to-workspace-down = { };
        "Mod+Ctrl+I".move-column-to-workspace-up = { };

        "Mod+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          focus-workspace-down = { };
        };
        "Mod+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          focus-workspace-up = { };
        };
        "Mod+Ctrl+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-down = { };
        };
        "Mod+Ctrl+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          move-column-to-workspace-up = { };
        };
        "Mod+WheelScrollRight" = {
          _props.cooldown-ms = 150;
          focus-column-right = { };
        };
        "Mod+WheelScrollLeft" = {
          _props.cooldown-ms = 150;
          focus-column-left = { };
        };
        "Mod+Ctrl+WheelScrollRight" = {
          _props.cooldown-ms = 150;
          move-column-right = { };
        };
        "Mod+Ctrl+WheelScrollLeft" = {
          _props.cooldown-ms = 150;
          move-column-left = { };
        };
        "Mod+Shift+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          focus-column-right = { };
        };
        "Mod+Shift+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          focus-column-left = { };
        };
        "Mod+Ctrl+Shift+WheelScrollDown" = {
          _props.cooldown-ms = 150;
          move-column-right = { };
        };
        "Mod+Ctrl+Shift+WheelScrollUp" = {
          _props.cooldown-ms = 150;
          move-column-left = { };
        };

        "Mod+O" = {
          _props.repeat = false;
          toggle-overview = { };
        };
        "Mod+Tab" = {
          _props.repeat = false;
          focus-workspace-previous = { };
        };

        "Mod+Shift+C" = {
          _props.repeat = false;
          close-window = { };
        };

        "Mod+R" = {
          _props.repeat = false;
          switch-preset-column-width = { };
        };
        "Mod+Shift+R" = {
          _props.repeat = false;
          switch-preset-window-height = { };
        };

        "Mod+BracketLeft" = {
          _props.repeat = false;
          consume-or-expel-window-left = { };
        };
        "Mod+BracketRight" = {
          _props.repeat = false;
          consume-or-expel-window-right = { };
        };
        "Mod+Comma" = {
          _props.repeat = false;
          consume-window-into-column = { };
        };
        "Mod+Period" = {
          _props.repeat = false;
          expel-window-from-column = { };
        };

        "Mod+F" = {
          _props.repeat = false;
          maximize-window-to-edges = { };
        };
        "Mod+Shift+F" = {
          _props.repeat = false;
          fullscreen-window = { };
        };

        "Mod+E" = {
          _props.repeat = false;
          center-column = { };
        };
        "Mod+Ctrl+E" = {
          _props.repeat = false;
          center-visible-columns = { };
        };

        "Mod+Minus".set-column-width = "-10%";
        "Mod+Equal".set-column-width = "+10%";
        "Mod+Shift+Minus".set-window-height = "-10%";
        "Mod+Shift+Equal".set-window-height = "+10%";

        "Mod+Space" = {
          _props.repeat = false;
          toggle-window-floating = { };
        };
        "Mod+Shift+Space" = {
          _props.repeat = false;
          switch-focus-between-floating-and-tiling = { };
        };

        "Mod+Print" = {
          _props.repeat = false;
          screenshot._props = {
            show-pointer = false;
          };
        };
        "Mod+Shift+Print" = {
          _props.repeat = false;
          screenshot-window._props = {
            show-pointer = false;
          };
        };
        "Mod+Ctrl+Print" = {
          _props.repeat = false;
          screenshot-screen._props = {
            show-pointer = false;
          };
        };

        "Mod+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = { };
        };
      };
    };
  };
}
