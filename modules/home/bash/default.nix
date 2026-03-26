{ ... }:

{
  programs.bash = {
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

    historySize = 20000;

    historyFile = "$HOME/.bash_history";

    bashrcExtra = ''
      # --- History behavior ---
      shopt -s histappend
      PROMPT_COMMAND="history -a; history -n"

      # --- Case-insensitive completion ---
      bind "set completion-ignore-case on"
      bind "set show-all-if-ambiguous on"

      # --- Right prompt (simulated) ---
      # Bash doesn't support RPROMPT natively,
      # so we inject it into PS1

      function nix_shell_prompt() {
        if [[ -n "$IN_NIX_SHELL" ]]; then
          printf "\[\e[37m\]❄\[\e[0m\] "
        fi
      }

      PS1='\u@\h:\w $(nix_shell_prompt)\$ '
    '';
  };
}
