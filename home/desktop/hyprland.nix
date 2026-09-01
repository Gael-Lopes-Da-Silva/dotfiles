{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

  screenshot = mode: ''hl.dsp.exec_cmd("hyprshot -m ${mode} -z --clipboard-only")'';

  bindMod = key: action: {
    _args = [
      (mkLuaInline ''mod .. " + ${key}"'')
      (mkLuaInline action)
    ];
  };

  bindKey = key: action: {
    _args = [
      key
      (mkLuaInline action)
    ];
  };

  gesture =
    {
      fingers ? 3,
      direction,
      mods ? null,
      action,
    }:
    lib.filterAttrs (_: v: v != null) {
      inherit fingers direction action;
      mods = mods;
    };

  workspaceBinds = lib.concatLists (
    lib.genList (
      i:
      let
        ws = toString (i + 1);
      in
      [
        (bindMod ws "hl.dsp.focus({ workspace = ${ws} })")
        (bindMod "SHIFT + ${ws}" "hl.dsp.window.move({ workspace = ${ws} })")
        (bindMod "CTRL + ${ws}" "hl.dsp.window.move({ workspace = ${ws}, follow = false })")
      ]
    ) 9
  );
in
{
  home.packages = with pkgs; [
    hyprshot
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      mod = {
        _var = "SUPER";
      };

      monitor = {
        output = "";
        mode = "preferred";
        position = "auto";
        scale = "auto";
      };

      on = {
        _args = [
          "hyprland.start"
          (mkLuaInline ''
            function()
              hl.exec_cmd("bash ~/.local/bin/autostart.sh")
            end
          '')
        ];
      };

      config = [
        {
          general = {
            gaps_in = 10;
            gaps_out = 10;
            layout = "scrolling";
            resize_on_border = false;
            allow_tearing = false;

            border_size = 1;
            col.active_border = "rgb(404040)";
            col.inactive_border = "rgb(303030)";
          };

          decoration = {
            rounding = 12;

            shadow = {
              enabled = true;
              render_power = 4;
              range = 10;
              color = "rgba(00000070)";
              color_inactive = "rgba(00000050)";
              offset = "0 2";
            };
          };

          animations = {
            enabled = true;
          };
        }
        {
          scrolling = {
            column_width = 1.0;
            explicit_column_widths = "0.5, 1.0";
            direction = "right";
            follow_focus = true;
            wrap_focus = true;
            wrap_swapcol = true;
          };
        }
        {
          group = {
            auto_group = 0;

            col = {
              border_active = "0";
              border_inactive = "0";
            };

            groupbar = {
              enabled = true;
              gaps_in = 3;
              gaps_out = 6;
              height = 0;
              rounding = 8;
            };
          };
        }
        {
          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            background_color = "#303030";
            focus_on_activate = true;
            mouse_move_enables_dpms = true;
            key_press_enables_dpms = true;
          };
        }
        {
          input = {
            kb_layout = "us";
            kb_variant = "intl";
            follow_mouse = 1;
            follow_mouse_threshold = 0;

            touchpad = {
              natural_scroll = true;
              tap_to_click = true;
            };
          };
        }
        {
          binds = {
            scroll_event_delay = 150;
          };
        }
        {
          gestures = {
            workspace_swipe_touch = true;
          };
        }
      ];

      curve = [
        {
          _args = [
            "easeOutExpo"
            {
              type = "bezier";
              points = [
                [
                  0.16
                  1
                ]
                [
                  0.3
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "easeOutQuad"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  1
                ]
                [
                  0.25
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "niriMove"
            {
              type = "spring";
              mass = 1;
              stiffness = 800;
              dampening = 56.57;
            }
          ];
        }
        {
          _args = [
            "niriWorkspace"
            {
              type = "spring";
              mass = 1;
              stiffness = 1000;
              dampening = 63.25;
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 1.5;
          spring = "niriMove";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 1.5;
          spring = "niriMove";
          style = "slide";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutExpo";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutQuad";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 1.5;
          spring = "niriMove";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 1.5;
          spring = "niriWorkspace";
          style = "slidevert";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutQuad";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutExpo";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutQuad";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 1.5;
          bezier = "easeOutQuad";
        }
        {
          leaf = "zoomFactor";
          enabled = true;
          speed = 2.0;
          spring = "niriMove";
        }
      ];

      gesture = [
        (gesture {
          direction = "vertical";
          action = "workspace";
        })

        (gesture {
          direction = "horizontal";
          action = "scroll_move";
        })
      ];

      bind = [
        (bindMod "RETURN" ''hl.dsp.exec_cmd("kgx")'')
        (bindMod "BackSpace" ''hl.dsp.exec_cmd("firefox")'')

        (bindMod "P" ''hl.dsp.exec_cmd("menu --applications")'')
        (bindMod "Q" ''hl.dsp.exec_cmd("menu --power")'')

        (bindMod "N" ''hl.dsp.exec_cmd("bash ~/.local/bin/datetime_notify.sh")'')
        (bindMod "B" ''hl.dsp.exec_cmd("bash ~/.local/bin/battery_notify.sh")'')

        (bindMod "CTRL + C" ''hl.dsp.exec_cmd("bash ~/.local/bin/kill_process.sh")'')
        (bindMod "CTRL + F" ''hl.dsp.exec_cmd("bash ~/.local/bin/freeze_process.sh")'')

        (bindKey "XF86AudioRaiseVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0")'')
        (bindKey "XF86AudioLowerVolume" ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-")'')
        (bindKey "XF86AudioMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'')
        (bindKey "XF86AudioMicMute" ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'')

        (bindKey "XF86AudioPlay" ''hl.dsp.exec_cmd("playerctl play-pause")'')
        (bindKey "XF86AudioStop" ''hl.dsp.exec_cmd("playerctl stop")'')
        (bindKey "XF86AudioPrev" ''hl.dsp.exec_cmd("playerctl previous")'')
        (bindKey "XF86AudioNext" ''hl.dsp.exec_cmd("playerctl next")'')

        (bindKey "XF86MonBrightnessUp" ''hl.dsp.exec_cmd("brightnessctl --class=backlight set +10%")'')
        (bindKey "XF86MonBrightnessDown" ''hl.dsp.exec_cmd("brightnessctl --class=backlight set 10%-")'')

        (bindMod "left" ''hl.dsp.layout("focus l")'')
        (bindMod "down" ''hl.dsp.focus({ direction = "down" })'')
        (bindMod "up" ''hl.dsp.focus({ direction = "up" })'')
        (bindMod "right" ''hl.dsp.layout("focus r")'')
        (bindMod "H" ''hl.dsp.layout("focus l")'')
        (bindMod "J" ''hl.dsp.focus({ direction = "down" })'')
        (bindMod "K" ''hl.dsp.focus({ direction = "up" })'')
        (bindMod "L" ''hl.dsp.layout("focus r")'')

        (bindMod "CTRL + left" ''hl.dsp.layout("swapcol l")'')
        (bindMod "CTRL + down" ''hl.dsp.window.move({ direction = "down" })'')
        (bindMod "CTRL + up" ''hl.dsp.window.move({ direction = "up" })'')
        (bindMod "CTRL + right" ''hl.dsp.layout("swapcol r")'')
        (bindMod "CTRL + H" ''hl.dsp.layout("swapcol l")'')
        (bindMod "CTRL + J" ''hl.dsp.window.move({ direction = "down" })'')
        (bindMod "CTRL + K" ''hl.dsp.window.move({ direction = "up" })'')
        (bindMod "CTRL + L" ''hl.dsp.layout("swapcol r")'')

        (bindMod "Home" ''hl.dsp.layout("fit tobeg")'')
        (bindMod "End" ''hl.dsp.layout("fit toend")'')
        (bindMod "CTRL + Home" ''hl.dsp.layout("swapcol l")'')
        (bindMod "CTRL + End" ''hl.dsp.layout("swapcol r")'')

        (bindMod "SHIFT + left" ''hl.dsp.focus({ monitor = "l" })'')
        (bindMod "SHIFT + down" ''hl.dsp.focus({ monitor = "d" })'')
        (bindMod "SHIFT + up" ''hl.dsp.focus({ monitor = "u" })'')
        (bindMod "SHIFT + right" ''hl.dsp.focus({ monitor = "r" })'')
        (bindMod "SHIFT + H" ''hl.dsp.focus({ monitor = "l" })'')
        (bindMod "SHIFT + J" ''hl.dsp.focus({ monitor = "d" })'')
        (bindMod "SHIFT + K" ''hl.dsp.focus({ monitor = "u" })'')
        (bindMod "SHIFT + L" ''hl.dsp.focus({ monitor = "r" })'')

        (bindMod "SHIFT + CTRL + left" ''hl.dsp.window.move({ monitor = "l" })'')
        (bindMod "SHIFT + CTRL + down" ''hl.dsp.window.move({ monitor = "d" })'')
        (bindMod "SHIFT + CTRL + up" ''hl.dsp.window.move({ monitor = "u" })'')
        (bindMod "SHIFT + CTRL + right" ''hl.dsp.window.move({ monitor = "r" })'')
        (bindMod "SHIFT + CTRL + H" ''hl.dsp.window.move({ monitor = "l" })'')
        (bindMod "SHIFT + CTRL + J" ''hl.dsp.window.move({ monitor = "d" })'')
        (bindMod "SHIFT + CTRL + K" ''hl.dsp.window.move({ monitor = "u" })'')
        (bindMod "SHIFT + CTRL + L" ''hl.dsp.window.move({ monitor = "r" })'')

        (bindMod "Page_Down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (bindMod "Page_Up" ''hl.dsp.focus({ workspace = "e-1" })'')
        (bindMod "U" ''hl.dsp.focus({ workspace = "e+1" })'')
        (bindMod "I" ''hl.dsp.focus({ workspace = "e-1" })'')
        (bindMod "SHIFT + Page_Down" ''hl.dsp.workspace.move({ monitor = "d" })'')
        (bindMod "SHIFT + Page_Up" ''hl.dsp.workspace.move({ monitor = "u" })'')
        (bindMod "SHIFT + U" ''hl.dsp.workspace.move({ monitor = "d" })'')
        (bindMod "SHIFT + I" ''hl.dsp.workspace.move({ monitor = "u" })'')
        (bindMod "CTRL + Page_Down" ''hl.dsp.window.move({ workspace = "e+1", follow = false })'')
        (bindMod "CTRL + Page_Up" ''hl.dsp.window.move({ workspace = "e-1", follow = false })'')
        (bindMod "CTRL + U" ''hl.dsp.window.move({ workspace = "e+1", follow = false })'')
        (bindMod "CTRL + I" ''hl.dsp.window.move({ workspace = "e-1", follow = false })'')

        (bindMod "mouse_down" ''hl.dsp.focus({ workspace = "e+1" })'')
        (bindMod "mouse_up" ''hl.dsp.focus({ workspace = "e-1" })'')
        (bindMod "CTRL + mouse_down" ''hl.dsp.window.move({ workspace = "e+1", follow = false })'')
        (bindMod "CTRL + mouse_up" ''hl.dsp.window.move({ workspace = "e-1", follow = false })'')
        (bindMod "mouse:276" ''hl.dsp.layout("focus r")'')
        (bindMod "mouse:275" ''hl.dsp.layout("focus l")'')
        (bindMod "CTRL + mouse:276" ''hl.dsp.layout("swapcol r")'')
        (bindMod "CTRL + mouse:275" ''hl.dsp.layout("swapcol l")'')
        (bindMod "SHIFT + mouse_down" ''hl.dsp.layout("focus r")'')
        (bindMod "SHIFT + mouse_up" ''hl.dsp.layout("focus l")'')
        (bindMod "SHIFT + CTRL + mouse_down" ''hl.dsp.layout("swapcol r")'')
        (bindMod "SHIFT + CTRL + mouse_up" ''hl.dsp.layout("swapcol l")'')

        (bindMod "mouse:272" "hl.dsp.window.drag()")

        (bindMod "S" ''hl.dsp.workspace.toggle_special("magic")'')
        (bindMod "SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')
        (bindMod "CTRL + S" ''hl.dsp.window.move({ workspace = "special:magic", follow = false })'')

        (bindMod "Tab" ''hl.dsp.focus({ workspace = "previous" })'')

        (bindMod "SHIFT + C" "hl.dsp.window.close()")

        (bindMod "R" ''hl.dsp.layout("colresize +conf")'')

        (bindMod "T" "hl.dsp.group.toggle()")

        (bindMod "bracketleft" ''hl.dsp.layout("consume_or_expel prev")'')
        (bindMod "bracketright" ''hl.dsp.layout("consume_or_expel next")'')
        (bindMod "comma" ''hl.dsp.layout("consume")'')
        (bindMod "period" ''hl.dsp.layout("expel")'')

        (bindMod "F" ''hl.dsp.layout("fit expand")'')
        (bindMod "SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')

        (bindMod "E" ''hl.dsp.layout("fit active")'')
        (bindMod "CTRL + E" ''hl.dsp.layout("fit visible")'')

        (bindMod "minus" ''hl.dsp.layout("colresize -0.1")'')
        (bindMod "equal" ''hl.dsp.layout("colresize +0.1")'')

        (bindMod "Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (bindMod "SHIFT + Space" ''hl.dsp.focus({ window = "floating" })'')

        (bindMod "Print" (screenshot "region"))
        (bindMod "SHIFT + Print" (screenshot "window"))
        (bindMod "CTRL + Print" (screenshot "output"))

        (bindMod "escape" ''hl.dsp.global("shortcuts:inhibit")'')
      ]
      ++ workspaceBinds;

      window_rule = [
        {
          name = "suppress-maximize-events";
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
      ];
    };
  };
}
