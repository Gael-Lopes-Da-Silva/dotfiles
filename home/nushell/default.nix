{ ... }:

{
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
      def create_right_prompt [] {
        let nix_shell = ($env | get -o IN_NIX_SHELL)
        if ($nix_shell | is-not-empty) {
          $"❄"
        }
      }

      $env.PROMPT_COMMAND_RIGHT = { create_right_prompt }
    '';
  };
}
