{ pkgs, ... }:

{
  home.packages = with pkgs; [
    bash-completion
    bash-language-server
  ];

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

    sessionVariables = {
      FZF_CTRL_R_OPTS = ''
        --layout=reverse
      '';
      FZF_CTRL_T_OPTS = ''
        --layout=reverse
        --walker-skip .git,node_modules,target
      '';
      FZF_ALT_C_OPTS = ''
        --layout=reverse
        --walker-skip .git,node_modules,target
      '';
    };

    historySize = 20000;
    historyFile = "$HOME/.bash_history";
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historyIgnore = [
      "ls"
      "cd"
      "exit"
    ];

    initExtra = ''
      bind "set completion-ignore-case on"
      bind "set show-all-if-ambiguous on"
      bind "TAB:menu-complete"
      bind "\"\e[Z\":menu-complete-backward"

      function set_right_prompt() {
        if [[ -n "$IN_NIX_SHELL" ]]; then
          RIGHT_PROMPT="\[\e[37m\]❄\[\e[0m\]"
        else
          RIGHT_PROMPT=""
        fi
      }

      function set_prompt() {
        set_right_prompt

        PS1="\u@\h:\w\$ "

        if [[ -n "$RIGHT_PROMPT" ]]; then
          PS1="$PS1\[\e[s\]\[\e[999C\]$RIGHT_PROMPT\[\e[u\]"
        fi
      }

      PROMPT_COMMAND="set_prompt; history -a; history -n"
    '';
  };
}
