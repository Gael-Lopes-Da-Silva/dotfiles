{ ... }:

{
  wayland.windowManager.niri = {
    enable = true;

    settings = {
      spawn-sh-at-startup = "bash ~/.local/bin/autostart.sh";

      prefer-no-csd = { };
      screenshot-path = null;

      input = {
        keyboard.xkb.layout = "us";
        keyboard.xkb.variant = "intl";

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
        border.off = { };

        tab-indicator = {
          gap = 3;
          gaps-between-tabs = 6;
          corner-radius = 8;
        };

        shadow = {
          on = { };
          softness = 8;
          spread = 2;
          color = "#00000070";
          inactive-color = "#00000054";
          offset._props = {
            x = 0;
            y = 5;
          };
        };
      };

      overview.zoom = 0.45;

      hotkey-overlay.skip-at-startup = { };

      clipboard.disable-primary = { };

      gestures.hot-corners.off = { };

      cursor.xcursor-size = 24;

      recent-windows.off = { };

      _children = [
        {
          window-rule._children = [
            { geometry-corner-radius = 12; }
            { clip-to-geometry = true; }
            { open-maximized-to-edges = false; }
            { draw-border-with-background = false; }
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
            { geometry-corner-radius = 0; }
            { open-focused = false; }
            { open-floating = true; }
            {
              default-floating-position._props = {
                x = 0;
                y = 0;
                relative-to = "bottom-right";
              };
            }
            { border.off = { }; }
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

        "Mod+1".focus-workspace = 1;
        "Mod+2".focus-workspace = 2;
        "Mod+3".focus-workspace = 3;
        "Mod+4".focus-workspace = 4;
        "Mod+5".focus-workspace = 5;
        "Mod+6".focus-workspace = 6;
        "Mod+7".focus-workspace = 7;
        "Mod+8".focus-workspace = 8;
        "Mod+9".focus-workspace = 9;
        "Mod+Shift+1".move-window-to-workspace = 1;
        "Mod+Shift+2".move-window-to-workspace = 2;
        "Mod+Shift+3".move-window-to-workspace = 3;
        "Mod+Shift+4".move-window-to-workspace = 4;
        "Mod+Shift+5".move-window-to-workspace = 5;
        "Mod+Shift+6".move-window-to-workspace = 6;
        "Mod+Shift+7".move-window-to-workspace = 7;
        "Mod+Shift+8".move-window-to-workspace = 8;
        "Mod+Shift+9".move-window-to-workspace = 9;
        "Mod+Ctrl+1".move-column-to-workspace = 1;
        "Mod+Ctrl+2".move-column-to-workspace = 2;
        "Mod+Ctrl+3".move-column-to-workspace = 3;
        "Mod+Ctrl+4".move-column-to-workspace = 4;
        "Mod+Ctrl+5".move-column-to-workspace = 5;
        "Mod+Ctrl+6".move-column-to-workspace = 6;
        "Mod+Ctrl+7".move-column-to-workspace = 7;
        "Mod+Ctrl+8".move-column-to-workspace = 8;
        "Mod+Ctrl+9".move-column-to-workspace = 9;

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

        "Mod+T" = {
          _props.repeat = false;
          toggle-column-tabbed-display = { };
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
          spawn-sh = [ "niri msg action screenshot --path '' --show-pointer false" ];
        };
        "Mod+Shift+Print" = {
          _props.repeat = false;
          spawn-sh = [ "niri msg action screenshot-window --path ''" ];
        };
        "Mod+Ctrl+Print" = {
          _props.repeat = false;
          spawn-sh = [ "niri msg action screenshot-screen --path '' --show-pointer false" ];
        };

        "Mod+Escape" = {
          _props.allow-inhibiting = false;
          toggle-keyboard-shortcuts-inhibit = { };
        };
      };
    };
  };
}
