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
          let home = ($env.HOME | path expand)
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
