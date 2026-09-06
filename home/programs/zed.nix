{ pkgs, ... }:

{
  home.packages = with pkgs; [
    nil
    nixd
  ];

  programs.zed-editor = {
    enable = true;
    mutableUserSettings = false;
    mutableUserKeymaps = false;

    extensions = [
      "yellowed"
      "nix"
    ];

    userSettings = {
      hard_tabs = true;
      middle_click_paste = false;
      soft_wrap = "editor_width";
      unnecessary_code_fade = 0.5;
      window_decorations = "server";
      scroll_beyond_last_line = "off";
      buffer_line_height = "standard";
      ui_font_size = 18.0;
      buffer_font_size = 18.0;
      agent_ui_font_size = 18.0;
      agent_buffer_font_size = 18.0;
      theme = "Yellowed";

      features = {
        edit_prediction_provider = "none";
      };

      tabs = {
        file_icons = true;
        git_status = true;
        show_diagnostics = "all";
      };

      toolbar = {
        code_actions = true;
      };

      edit_predictions = {
        provider = "none";
      };

      project_panel = {
        auto_fold_dirs = false;
        hide_root = true;
      };

      collaboration_panel = {
        button = false;
      };

      title_bar = {
        show_sign_in = false;
        show_onboarding_banner = false;
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
