{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      zed-editor
    ];

    programs.zed-editor = {
      enable = true;
      extensions = [
        "yellowed"
        "nix"
        "php"
        "toml"
        "log"
        "html"
        "sql"
        "dockerfile"
      ];
      userSettings = {
        collaboration_panel = {
          default_width = 300.0;
        };
        notification_panel = {
          default_width = 300.0;
        };
        git_panel = {
          default_width = 300.0;
        };
        project_panel = {
          auto_fold_dirs = false;
          default_width = 300.0;
          hide_root = true;
        };
        window_decorations = "server";
        title_bar = {
          show_sign_in = false;
        };
        middle_click_paste = false;
        lsp_document_colors = "background";
        inlay_hints = {
          show_background = true;
        };
        completions = {
          words_min_length = 1;
        };
        format_on_save = "on";
        soft_wrap = "editor_width";
        minimap = {
          show = "auto";
        };
        gutter = {
          line_numbers = false;
        };
        drag_and_drop_selection = {
          enabled = false;
        };
        scroll_beyond_last_line = "off";
        which_key = {
          enabled = true;
        };
        git = {
          inline_blame = {
            enabled = false;
          };
        };
        disable_ai = true;
        buffer_line_height = "standard";
        telemetry = {
          diagnostics = false;
          metrics = false;
        };
        restore_on_startup = "empty_tab";
        ui_font_size = 18.0;
        buffer_font_size = 18.0;
        theme = "Yellowed";
      };
      userKeymaps = [
        {
          context = "Editor";
          bindings = {
            ctrl-enter = "editor::NewlineBelow";
          };
        }
        {
          context = "Editor";
          bindings = {
            ctrl-shift-enter = "editor::NewlineAbove";
          };
        }
      ];
    };
  };
}
