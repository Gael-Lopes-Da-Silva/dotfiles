{ config, pkgs, ... }:

{
  home-manager.users.gael = {
    home.packages = with pkgs; [
      bash
    ];

    programs.bash = {
      enable = true;

      historySize = 10000;
      historyFileSize = 20000;
      historyControl = [ "ignoreboth" ];

      shellAliases = {
        grep = "grep --color=auto";
        fgrep = "fgrep --color=auto";
        egrep = "egrep --color=auto";
        dir = "dir --color=auto";
        vdir = "vdir --color=auto";

        ls = "ls --color=auto --sort=extension --group-directories-first";
        la = "ls -Alh";
        ll = "ls -lh";

        cp = "cp -iprv";
        rm = "rm -rIdv";
        mv = "mv -iv";

        compress = "ouch compress";
        decompress = "ouch decompress";
      };

      sessionVariables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
        GIT_EDITOR = "nvim";
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

      initExtra = ''
        shopt -s checkwinsize histappend autocd dirspell cdspell cmdhist globstar extglob

        bind 'set show-all-if-ambiguous on'
        bind 'set mark-symlinked-directories on'
        bind 'set completion-ignore-case on'
        bind 'set colored-stats on'
        bind 'set enable-bracketed-paste off'

        bind 'TAB:menu-complete'
        bind '"\e[Z":menu-complete-backward'
        bind '"\e[A":history-search-backward'
        bind '"\e[B":history-search-forward'

        get_prompt() {
          if [ "$?" -eq 0 ]; then
            PS1="\[\e[92;1m\]\w\[\e[0m\]\n"
          else
            PS1="\[\e[91;1m\]\w\[\e[0m\]\n"
          fi
        }

        PROMPT_COMMAND=get_prompt
      '';
    };
  };
}
