{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      nushell
    ];

    programs.nushell = {
      enable = true;

      shellAliases = {
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";

        la = "ls -a";
        ll = "ls -l";

        cp = "cp -iv";
        rm = "rm -i";
        mv = "mv -iv";

        compress = "ouch compress";
        decompress = "ouch decompress";
      };

      environmentVariables = {
        EDITOR = "zeditor";
        VISUAL = "zeditor";
        GIT_EDITOR = "zeditor";
        GIT_PAGER = "less";
        TERMINAL = "alacritty";
        BROWSER = "firefox";
        PAGER = "less";

        LESS = "-R -F -X";
        LESSHISTFILE = "-";

        TERM = "xterm-256color";
        COLORTERM = "truecolor";

        VDPAU_DRIVER = "va_gl";
        MOZ_ENABLE_WAYLAND = "1";

        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_DATA_HOME = "$HOME/.local/share";
        XDG_CACHE_HOME = "$HOME/.cache";
        XDG_STATE_HOME = "$HOME/.local/state";

        LANG = "en_US.UTF-8";
        LC_ALL = "en_US.UTF-8";
        LC_CTYPE = "en_US.UTF-8";
        LC_TIME = "en_US.UTF-8";

        GTK_THEME = "Adwaita:dark";
        QT_QPA_PLATFORMTHEME = "qt5ct";
        QT_STYLE_OVERRIDE = "Fusion";
        QT_QUICK_CONTROLS_STYLE = "Fusion";
      };

      settings = {
        show_banner = false;

        history = {
          max_size = 20000;
          sync_on_enter = true;
          file_format = "plaintext";
        };

        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
        };
      };

      configFile.text = ''
        def create_left_prompt [] {
          let last_status = $env.LAST_EXIT_CODE
          let home = $nu.home-path
          let cwd = (pwd | path expand)

          let display_path = if $cwd == $home {
            "~"
          } else if ($cwd | str starts-with $home) {
            "~" + ($cwd | str replace $home "")
          } else {
            $cwd
          }

          if $last_status == 0 {
            $"(ansi green_bold)($display_path)(ansi reset)\n"
          } else {
            $"(ansi red_bold)($display_path)(ansi reset)\n"
          }
        }

        $env.PROMPT_COMMAND = { create_left_prompt }
        $env.PROMPT_COMMAND_RIGHT = {||}
      '';
    };
  };
}
