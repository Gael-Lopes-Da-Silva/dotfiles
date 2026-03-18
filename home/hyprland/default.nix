{ pkgs, ... }:

{
  home.packages = with pkgs; [
    hyprfreeze
    hyprpicker
    hyprpaper
    hyprshot
    hyprsunset
    hyprshade

    hyprgraphics
    hyprutils
    hyprcursor
    hyprland
    aquamarine
  ];

  wayland.windowManager.hyprland = {
    enable = true;
    systemd.enable = true;
    xwayland.enable = true;

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "alacritty";
      "$browser" = "firefox";

      exec-once = [
        "bash ~/.local/bin/soundboard_setup.sh &"
        "bash ~/.local/bin/audio_monitor.sh &"
        "bash ~/.local/bin/battery_monitor.sh &"
        "bash ~/.local/bin/brightness_monitor.sh &"
        "bash ~/.local/bin/output_monitor.sh"
      ];

      env = [
        "XCURSOR_SIZE,24"
        "HYPRCURSOR_SIZE,24"
      ];

      input = {
        kb_model = "";
        kb_layout = "us";
        kb_variant = "intl";
        kb_options = "";
        kb_rules = "";

        numlock_by_default = false;
        repeat_rate = 25;
        repeat_delay = 600;

        follow_mouse = 1;
        focus_on_close = 0;
        mouse_refocus = true;

        touchpad = {
          disable_while_typing = true;
          natural_scroll = true;
          tap-to-click = true;
          tap-and-drag = true;
        };
      };

      general = {
        gaps_in = 16;
        gaps_out = 16;

        border_size = 6;
        resize_on_border = false;
        allow_tearing = false;
        layout = "monocle";

        "col.active_border" = "rgb(FFC87F)";
        "col.inactive_border" = "rgb(595959)";
      };

      decoration = {
        rounding = 16;
        rounding_power = 2.0;

        active_opacity = 1.0;
        inactive_opacity = 1.0;
        fullscreen_opacity = 1.0;

        dim_modal = true;
        dim_inactive = false;
        dim_strength = 0.5;
        dim_special = 0.2;
        dim_around = 0.4;

        border_part_of_window = true;

        blur = {
          enabled = true;
          size = 8;
          passes = 1;
          ignore_opacity = true;
          new_optimizations = true;
          xray = false;

          special = false;
          popups = false;
          input_methods = false;
        };

        shadow = {
          enabled = true;
          range = 5;
          render_power = 10;
          ignore_window = true;
          offset = "0 0";
          scale = 1.0;
        };
      };

      animations = {
        enabled = true;

        animation = [
          "workspaces, 1, 5, default, slidevert"
        ];
      };

      gestures = {
        workspace_swipe_distance = 700;
        workspace_swipe_min_speed_to_force = 10;
        workspace_swipe_cancel_ratio = 0.2;
        workspace_swipe_create_new = true;
        workspace_swipe_direction_lock = true;
        workspace_swipe_forever = false;
        workspace_swipe_use_r = false;
      };

      gesture = [
        "3, vertical, workspace"
        "3, left, dispatcher, layoutmsg, cycleprev"
        "3, right, dispatcher, layoutmsg, cyclenext"
      ];

      group = {
        auto_group = true;
        insert_after_current = true;
        focus_removed_window = true;
        merge_groups_on_drag = true;
        merge_groups_on_groupbar = true;
        merge_floated_into_tiled_on_groupbar = false;
        group_on_movetoworkspace = false;

        groupbar = {
          enabled = true;
          indicator_gap = 0;
          indicator_height = 3;
          stacked = false;
          scrolling = true;
          rounding = 1;
          rounding_power = 2.0;
        };
      };

      misc = {
        background_color = "rgb(404040)";

        disable_hyprland_logo = true;
        disable_splash_rendering = false;
        disable_scale_notification = false;
        force_default_wallpaper = 0;
        always_follow_on_dnd = true;
        layers_hog_keyboard_focus = true;
        disable_autoreload = false;
        enable_swallow = false;
        focus_on_activate = false;
        mouse_move_focuses_monitor = true;
        close_special_on_empty = true;
        on_focus_under_fullscreen = 2;
        exit_window_retains_fullscreen = false;
        initial_workspace_tracking = 1;
        middle_click_paste = false;
        enable_anr_dialog = true;
        disable_watchdog_warning = true;
      };

      binds = {
        pass_mouse_when_bound = false;
        workspace_back_and_forth = false;
        hide_special_on_workspace_change = true;
        allow_workspace_cycles = false;
        workspace_center_on = 0;
        focus_preferred_method = 0;
        disable_keybind_grabbing = false;
        allow_pin_fullscreen = false;
      };

      cursor = {
        invisible = false;
        enable_hyprcursor = true;
        sync_gsettings_theme = true;
        no_warps = false;
        persistent_warps = false;
        warp_on_change_workspace = 0;
        warp_on_toggle_special = 0;
        hide_on_key_press = false;
        hide_on_touch = true;
        hide_on_tablet = true;
      };

      ecosystem = {
        no_update_news = true;
        no_donation_nag = true;
      };

      xwayland = {
        enabled = true;
        use_nearest_neighbor = true;
        force_zero_scaling = false;
      };

      windowrule = [
        {
          name = "suppress-maximize-events";

          "match:class" = ".*";

          suppress_event = "maximize";
        }
        {
          name = "fix-xwayland-drags";

          "match:class" = "^$";
          "match:title" = "^$";
          "match:xwayland" = true;
          "match:float" = true;
          "match:fullscreen" = false;
          "match:pin" = false;

          no_focus = true;
        }
        {
          name = "size-floating-windows";

          "match:float" = true;

          center = true;
          size = "monitor_w*0.6 monitor_h*0.6";
        }
        {
          name = "terminal-based-menus";

          "match:class" = "^(launcher|cliphist|soundboard|powermenu)$";

          float = true;
          center = true;
          size = "monitor_w*0.5 monitor_h*0.5";
        }
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, BackSpace, exec, $browser"

        "$mod, N, exec, bash ~/.local/bin/datetime_notify.sh"
        "$mod, B, exec, bash ~/.local/bin/battery_notify.sh"
        "$mod, V, exec, bash ~/.local/bin/cliphist_menu.sh"
        "$mod, M, exec, bash ~/.local/bin/soundboard_menu.sh"

        "$mod, P, exec, bash ~/.local/bin/application_menu.sh"
        "$mod SHIFT, P, exec, bash ~/.local/bin/command_menu.sh"

        "$mod, Q, exec, bash ~/.local/bin/power_menu.sh"
        "$mod SHIFT, Q, exec, bash ~/.local/bin/power_menu.sh"
        "CTRL ALT, Delete, exec, bash ~/.local/bin/power_menu.sh"

        ", XF86PowerOff, exec, bash ~/.local/bin/power_menu.sh"
        ", XF86AudioRaiseVolume, exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioPause, exec, playerctl play-pause"
        ", XF86AudioStop, exec, playerctl stop"
        ", XF86AudioPrev, exec, playerctl previous"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86MonBrightnessUp, exec, brightnessctl --class=backlight set +10%"
        ", XF86MonBrightnessDown, exec, brightnessctl --class=backlight set 10%-"

        "$mod, S, togglespecialworkspace, magic"
        "$mod SHIFT, S, movetoworkspace, special:magic"

        "$mod SHIFT, C, killactive,"
        "$mod CTRL, C, forcekillactive,"

        "$mod, Space, togglefloating,"

        "$mod, F, fullscreenstate, 2 0"
        "$mod SHIFT, F, fullscreenstate, 2 2"

        "$mod, left, layoutmsg, cycleprev"
        "$mod, right, layoutmsg, cyclenext"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, H, layoutmsg, cycleprev"
        "$mod, L, layoutmsg, cyclenext"
        "$mod, K, movefocus, u"
        "$mod, J, movefocus, d"

        "$mod SHIFT, left, movefocus, mon:l"
        "$mod SHIFT, right, movefocus, mon:r"
        "$mod SHIFT, up, movefocus, mon:u"
        "$mod SHIFT, down, movefocus, mon:d"
        "$mod SHIFT, H, movefocus, mon:l"
        "$mod SHIFT, L, movefocus, mon:r"
        "$mod SHIFT, K, movefocus, mon:u"
        "$mod SHIFT, J, movefocus, mon:d"

        "$mod, 1, workspace, r~1"
        "$mod, 2, workspace, r~2"
        "$mod, 3, workspace, r~3"
        "$mod, 4, workspace, r~4"
        "$mod, 5, workspace, r~5"
        "$mod, 6, workspace, r~6"
        "$mod, 7, workspace, r~7"
        "$mod, 8, workspace, r~8"
        "$mod, 9, workspace, r~9"
        "$mod, 0, workspace, r~10"

        "$mod SHIFT, 1, movetoworkspace, r~1"
        "$mod SHIFT, 2, movetoworkspace, r~2"
        "$mod SHIFT, 3, movetoworkspace, r~3"
        "$mod SHIFT, 4, movetoworkspace, r~4"
        "$mod SHIFT, 5, movetoworkspace, r~5"
        "$mod SHIFT, 6, movetoworkspace, r~6"
        "$mod SHIFT, 7, movetoworkspace, r~7"
        "$mod SHIFT, 8, movetoworkspace, r~8"
        "$mod SHIFT, 9, movetoworkspace, r~9"
        "$mod SHIFT, 0, movetoworkspace, r~10"

        "$mod, U, workspace, r+1"
        "$mod, I, workspace, r-1"
        "$mod, mouse_up, workspace, r+1"
        "$mod, mouse_down, workspace, r-1"
        "$mod, mouse_left, layoutmsg, cycleprev"
        "$mod, mouse_right, layoutmsg, cyclenext"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };
}
