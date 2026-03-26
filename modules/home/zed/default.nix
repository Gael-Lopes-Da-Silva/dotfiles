{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
  ];

  programs.zed-editor = {
    enable = true;

    extensions = [
      "yellowed"

      "nix"
      "php"
      "xml"
      "lua"
      "toml"
      "log"
      "html"
      "sql"
      "kdl"
      "twig"
      "make"
      "odin"
      "dockerfile"
      "git-firefly"
    ];

    userSettings = {
      middle_click_paste = false;
      window_decorations = "server";
      lsp_document_colors = "background";
      scroll_beyond_last_line = "off";
      format_on_save = "on";
      soft_wrap = "editor_width";
      disable_ai = true;
      buffer_line_height = "standard";
      restore_on_startup = "empty_tab";
      ui_font_size = 18.0;
      buffer_font_size = 18.0;
      theme = "Yellowed";

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

      title_bar = {
        show_sign_in = false;
      };

      inlay_hints = {
        show_background = true;
      };

      completions = {
        words_min_length = 1;
      };

      minimap = {
        show = "auto";
      };

      gutter = {
        line_numbers = false;
      };

      drag_and_drop_selection = {
        enabled = false;
      };

      which_key = {
        enabled = true;
      };

      git = {
        inline_blame = {
          enabled = false;
        };
      };

      terminal = {
        shell = {
          program = "nu";
        };
      };

      session = {
        trust_all_worktrees = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
      };
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
}
