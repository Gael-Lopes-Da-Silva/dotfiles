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
    ];

    userSettings = {
      middle_click_paste = false;
      window_decorations = "server";
      scroll_beyond_last_line = "off";
      format_on_save = "on";
      soft_wrap = "editor_width";
      buffer_line_height = "standard";
      ui_font_size = 18.0;
      buffer_font_size = 18.0;
      agent_ui_font_size = 18.0;
      agent_buffer_font_size = 18.0;
      theme = "Yellowed";

      edit_predictions = {
        provider = "none";
      };

      project_panel = {
        auto_fold_dirs = false;
        hide_root = true;
      };

      title_bar = {
        show_sign_in = false;
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

      session = {
        trust_all_worktrees = true;
      };

      telemetry = {
        diagnostics = false;
        metrics = false;
        anthropic_retention = false;
      };
    };

    userKeymaps = [
      {
        context = "Editor";
        bindings = {
          ctrl-enter = "editor::NewlineBelow";
          ctrl-shift-enter = "editor::NewlineAbove";
        };
      }
    ];
  };
}
