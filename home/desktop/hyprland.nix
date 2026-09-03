{ pkgs, lib, ... }:

let
  inherit (lib.generators) mkLuaInline;

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

  onEvent = event: handler: {
    _args = [
      event
      (mkLuaInline handler)
    ];
  };

  gesture =
    {
      fingers ? 3,
      direction,
      mods ? null,
      scale ? null,
      action,
    }:
    lib.filterAttrs (_: v: v != null) {
      inherit fingers direction action;
      mods = mods;
      scale = scale;
    };

  gestureFn =
    {
      fingers ? 4,
      direction,
      mods ? null,
      scale ? null,
      body,
    }:
    lib.filterAttrs (_: v: v != null) {
      inherit fingers direction;
      mods = mods;
      scale = scale;
      action = mkLuaInline body;
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
    hyprpicker
    hyprland-protocols
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    configType = "lua";

    settings = {
      mod = {
        _var = "SUPER";
      };

      on = [
        (onEvent "hyprland.start" ''
          function()
            hl.exec_cmd("bash ~/.local/bin/autostart.sh")
          end
        '')
        (onEvent "workspace.active" ''
          function(ws)
            hl.exec_cmd("bash ~/.local/bin/active_workspace.sh " .. ws.id)
          end
        '')
        (onEvent "screenshare.state" ''
          function(active, shareType, name)
            local function isLocalCapture()
              local proc = io.popen("pgrep -x hyprpicker >/dev/null 2>&1 || pgrep -f hyprshot >/dev/null 2>&1; echo $?")
              if not proc then
                return false
              end
              local code = proc:read("*a")
              proc:close()
              return code:match("^0") ~= nil
            end

            if active then
              if isLocalCapture() then
                localCaptureSessions = (localCaptureSessions or 0) + 1
                return
              end
            elseif (localCaptureSessions or 0) > 0 then
              localCaptureSessions = localCaptureSessions - 1
              return
            end

            hl.exec_cmd(string.format("bash ~/.local/bin/screenshare_state.sh %s %d %q", active and "true" or "false", shareType, name))
          end
        '')
      ];

      config = [
        {
          general = {
            gaps_in = 5;
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

            motion_blur.enabled = true;
          };

          animations.enabled = true;
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

            groupbar.enabled = false;
          };
        }
        {
          misc = {
            force_default_wallpaper = 0;
            disable_hyprland_logo = true;
            disable_splash_rendering = true;
            background_color = "rgb(303030)";
            middle_click_paste = false;
            disable_watchdog_warning = true;
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
            workspace_swipe_create_new = false;
            workspace_swipe_forever = false;
            workspace_swipe_distance = 180;
            workspace_swipe_cancel_ratio = 0.3;
          };
        }
        {
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
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
            "easeOutQuint"
            {
              type = "bezier";
              points = [
                [
                  0.23
                  1
                ]
                [
                  0.32
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "almostLinear"
            {
              type = "bezier";
              points = [
                [
                  0.5
                  0.5
                ]
                [
                  0.75
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "quick"
            {
              type = "bezier";
              points = [
                [
                  0.15
                  0
                ]
                [
                  0.1
                  1
                ]
              ];
            }
          ];
        }
        {
          _args = [
            "move"
            {
              type = "spring";
              mass = 1;
              stiffness = 280;
              dampening = 33.47;
            }
          ];
        }
        {
          _args = [
            "workspace"
            {
              type = "spring";
              mass = 1;
              stiffness = 360;
              dampening = 37.95;
            }
          ];
        }
      ];

      animation = [
        {
          leaf = "global";
          enabled = true;
          speed = 3;
          spring = "move";
        }
        {
          leaf = "windows";
          enabled = true;
          speed = 3.2;
          spring = "move";
          style = "slide";
        }
        {
          leaf = "windowsIn";
          enabled = true;
          speed = 2.8;
          spring = "move";
          style = "slide";
        }
        {
          leaf = "windowsOut";
          enabled = true;
          speed = 2;
          spring = "move";
          style = "slide";
        }
        {
          leaf = "windowsMove";
          enabled = true;
          speed = 3.2;
          spring = "move";
        }
        {
          leaf = "workspaces";
          enabled = true;
          speed = 2.4;
          spring = "workspace";
          style = "slidevert";
        }
        {
          leaf = "workspacesIn";
          enabled = true;
          speed = 2;
          spring = "workspace";
          style = "slidevert";
        }
        {
          leaf = "workspacesOut";
          enabled = true;
          speed = 2.6;
          spring = "workspace";
          style = "slidevert";
        }
        {
          leaf = "fade";
          enabled = true;
          speed = 2.5;
          bezier = "quick";
        }
        {
          leaf = "fadeIn";
          enabled = true;
          speed = 2;
          bezier = "almostLinear";
        }
        {
          leaf = "fadeOut";
          enabled = true;
          speed = 1.6;
          bezier = "almostLinear";
        }
        {
          leaf = "border";
          enabled = true;
          speed = 3;
          bezier = "easeOutQuint";
        }
        {
          leaf = "zoomFactor";
          enabled = true;
          speed = 4;
          spring = "move";
        }
        {
          leaf = "layers";
          enabled = true;
          speed = 2.5;
          bezier = "easeOutQuint";
        }
        {
          leaf = "layersIn";
          enabled = true;
          speed = 2.2;
          spring = "move";
          style = "slide";
        }
        {
          leaf = "layersOut";
          enabled = true;
          speed = 1.8;
          spring = "move";
          style = "slide";
        }
        {
          leaf = "fadeLayers";
          enabled = true;
          speed = 2;
          bezier = "quick";
        }
        {
          leaf = "fadeLayersIn";
          enabled = true;
          speed = 1.8;
          bezier = "easeOutExpo";
        }
        {
          leaf = "fadeLayersOut";
          enabled = true;
          speed = 1.5;
          bezier = "almostLinear";
        }
      ];

      layer_rule = [
        {
          name = "notifications-animation";
          match = {
            namespace = "notifications";
          };
          animation = "slide";
        }
        {
          name = "no-anim-selection";
          match = {
            namespace = "selection";
          };
          no_anim = true;
        }
        {
          name = "no-anim-hyprpicker";
          match = {
            namespace = "hyprpicker";
          };
          no_anim = true;
        }
      ];

      window_rule = [
        {
          name = "suppress-maximize-events";
          match = {
            class = ".*";
          };
          suppress_event = "maximize";
        }
        {
          name = "steam-notifications";
          match = {
            class = "^steam$";
            title = "^notificationtoasts";
          };
          rounding = 0;
          no_initial_focus = true;
          float = true;
          move = [
            "monitor_w - window_w"
            "monitor_h - window_h"
          ];
          border_size = 0;
        }
        {
          name = "make-window-float";
          match = {
            class = "^.*gradia$";
            title = "^Gradia$";
          };
          float = true;
        }
      ];

      gesture = [
        (gesture {
          direction = "vertical";
          action = "workspace";
          scale = 0.4;
        })
        (gesture {
          direction = "horizontal";
          action = "scroll_move";
          scale = 1.8;
        })
        (gestureFn {
          direction = "up";
          scale = 1.0;
          body = ''
            function()
              local ws = hl.get_workspace("special:magic")
              if ws ~= nil and not ws.active then
                hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
              end
            end
          '';
        })
        (gestureFn {
          direction = "down";
          scale = 1.0;
          body = ''
            function()
              local ws = hl.get_workspace("special:magic")
              if ws ~= nil and ws.active then
                hl.dispatch(hl.dsp.workspace.toggle_special("magic"))
              end
            end
          '';
        })
      ];

      bind = [
        (bindMod "RETURN" ''hl.dsp.exec_cmd("kgx")'')
        (bindMod "BackSpace" ''hl.dsp.exec_cmd("firefox")'')

        (bindMod "P" ''hl.dsp.exec_cmd("menu --applications")'')
        (bindMod "Q" ''hl.dsp.exec_cmd("menu --power")'')

        (bindMod "N" ''hl.dsp.exec_cmd("bash ~/.local/bin/datetime_notify.sh")'')
        (bindMod "B" ''hl.dsp.exec_cmd("bash ~/.local/bin/battery_notify.sh")'')
        (bindMod "W" ''hl.dsp.exec_cmd("bash ~/.local/bin/workspace_notify.sh")'')

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
        (bindMod "mouse:273" "hl.dsp.window.resize()")

        (bindMod "S" ''hl.dsp.workspace.toggle_special("magic")'')
        (bindMod "SHIFT + S" ''hl.dsp.window.move({ workspace = "special:magic" })'')
        (bindMod "CTRL + S" ''hl.dsp.window.move({ workspace = "special:magic", follow = false })'')

        (bindMod "Tab" ''hl.dsp.focus({ workspace = "previous" })'')

        (bindMod "SHIFT + C" "hl.dsp.window.close()")

        (bindMod "O" ''hl.dsp.exec_cmd("coulr")'')

        (bindMod "R" ''hl.dsp.layout("colresize +conf")'')

        (bindMod "bracketleft" ''hl.dsp.layout("consume_or_expel prev")'')
        (bindMod "bracketright" ''hl.dsp.layout("consume_or_expel next")'')
        (bindMod "comma" ''hl.dsp.layout("consume")'')
        (bindMod "period" ''hl.dsp.layout("expel")'')

        (bindMod "F" ''hl.dsp.window.fullscreen({ mode = "maximized" })'')
        (bindMod "SHIFT + F" ''hl.dsp.window.fullscreen({ mode = "fullscreen" })'')

        (bindMod "E" ''hl.dsp.layout("fit active")'')
        (bindMod "CTRL + E" ''hl.dsp.layout("fit visible")'')

        (bindMod "minus" ''hl.dsp.layout("colresize -0.1")'')
        (bindMod "equal" ''hl.dsp.layout("colresize +0.1")'')

        (bindMod "Space" ''hl.dsp.window.float({ action = "toggle" })'')
        (bindMod "SHIFT + Space" ''hl.dsp.focus({ window = "floating" })'')

        (bindMod "Print" ''hl.dsp.exec_cmd("gradia --screenshot")'')

        (bindMod "escape" ''hl.dsp.global("shortcuts:inhibit")'')
      ]
      ++ workspaceBinds;
    };
  };
}
