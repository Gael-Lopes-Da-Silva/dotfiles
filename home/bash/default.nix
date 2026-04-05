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

      compress = "7z a -tzip";
      decompress = "7z x";
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

    profileExtra = ''
      export LESS_TERMCAP_md=$'\e[01;31m'
      export LESS_TERMCAP_me=$'\e[0m'
      export LESS_TERMCAP_se=$'\e[0m'
      export LESS_TERMCAP_so=$'\e[01;44;33m'
      export LESS_TERMCAP_ue=$'\e[0m'
      export LESS_TERMCAP_us=$'\e[01;32m'
      export GROFF_NO_SGR=1
    '';

    initExtra = ''
      bind "set completion-ignore-case on"
      bind "set show-all-if-ambiguous on"
      bind "TAB:menu-complete"
      bind "\"\e[Z\":menu-complete-backward"

      function set_prompt() {
        PS1="\u@\h:\w''${IN_NIX_SHELL:+ ❄}\n\$ "
      }

      PROMPT_COMMAND="set_prompt"
    '';
  };
}
