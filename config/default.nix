{ pkgs, config, ... }:

{
  system.stateVersion = "25.11";

  nix = {
    optimise = {
      automatic = true;
      persistent = true;
      dates = "daily";
    };

    settings = {
      cores = 8;
      max-jobs = "auto";
      auto-optimise-store = true;

      experimental-features = [
        "nix-command"
        "flakes"
      ];

      trusted-users = [
        "root"
        "gael"
      ];
    };

    gc = {
      automatic = true;
      persistent = true;
      dates = "daily";
      options = "--delete-older-than 5d";
    };
  };

  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };

      efi.canTouchEfiVariables = true;
    };

    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "v4l2loopback" ];

    extraModulePackages = with config.boot.kernelPackages; [
      v4l2loopback
    ];

    tmp = {
      cleanOnBoot = true;
      useTmpfs = true;
    };
  };

  hardware = {
    uinput = {
      enable = true;
    };

    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
  };

  documentation = {
    enable = true;
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    nixos.enable = false;

    man = {
      enable = true;

      cache = {
        enable = true;
        generateAtRuntime = true;
      };
    };
  };

  programs = {
    nix-ld.enable = true;
    niri.enable = true;
  };

  services = {
    gvfs.enable = true;
    lact.enable = true;
    upower.enable = true;
    udisks2.enable = true;
    libinput.enable = true;
    power-profiles-daemon.enable = true;

    gnome = {
      gnome-keyring.enable = true;
    };

    logind = {
      settings = {
        Login = {
          HoldoffTimeoutSec = "1s";
          HandleLidSwitch = "suspend";
        };
      };
    };

    displayManager.ly = {
      enable = true;

      settings = {
        animation = "none";
        session_log = ".cache/ly/session.log";
        clock = null;
        bigclock = true;
        blank_box = false;
        hide_borders = true;
        corner_bottom_left = "";
        corner_bottom_right = "";
        corner_top_left = "";
        corner_top_right = "numlock,capslock";
        load = true;
        save = true;
      };
    };

    udev = {
      packages = with pkgs; [
        via
        vial

        qmk
        qmk_hid
        qmk-udev-rules
      ];
    };

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;

      audio.enable = true;
      wireplumber.enable = true;

      extraConfig = {
        pipewire = {
          "context.properties" = {
            "default.clock.rate" = 48000;
            "default.clock.quantum" = 2048;
            "default.clock.min-quantum" = 2048;
            "default.clock.max-quantum" = 8192;
          };
        };
      };
    };
  };

  environment = {
    variables = {
      EDITOR = "zeditor";
      VISUAL = "zeditor";
      TERMINAL = "kgx";
      BROWSER = "firefox";
      PAGER = "less";
      LESS = "-R --use-color";

      TERM = "xterm-256color";
      COLORTERM = "truecolor";

      VDPAU_DRIVER = "va_gl";
      MOZ_ENABLE_WAYLAND = "1";

      XDG_CONFIG_HOME = "$HOME/.config";
      XDG_DATA_HOME = "$HOME/.local/share";
      XDG_CACHE_HOME = "$HOME/.cache";
      XDG_STATE_HOME = "$HOME/.local/state";

      QT_QPA_PLATFORM = "wayland";
      QT_QPA_PLATFORMTHEME = "adwaita";
      QT_STYLE_OVERRIDE = "adwaita-dark";
      QT_QUICK_CONTROLS_STYLE = "adwaita-dark";
    };

    systemPackages = with pkgs; [
      man-pages
      man-pages-posix
      qadwaitadecorations
      qadwaitadecorations-qt6
      qgnomeplatform
      qgnomeplatform-qt6
    ];
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-lgc-plus
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      noto-fonts-monochrome-emoji

      nerd-fonts.symbols-only
    ];
  };

  time = {
    timeZone = "Europe/Paris";
  };

  i18n = {
    inputMethod = {
      enable = true;
      type = "ibus";
    };

    defaultLocale = "en_US.UTF-8";
    defaultCharset = "UTF-8";
  };

  users = {
    users.gael = {
      isNormalUser = true;
      extraGroups = [
        "disk"
        "input"
        "wheel"
        "audio"
        "video"
        "uinput"
      ];
    };
  };

  home-manager = {
    users.gael = {
      home = {
        stateVersion = "26.05";

        sessionPath = [
          "$HOME/.local/bin"
        ];

        pointerCursor = {
          enable = true;
          gtk.enable = true;
          package = pkgs.bibata-cursors;
          name = "Bibata-Modern-Classic";
          size = 24;
        };

        packages = with pkgs; [
          nil
          nixd

          gtk3
          gtk4
          glib
          playerctl
          libsecret
          libnotify
          pulseaudio
          wl-clipboard
          brightnessctl

          adwaita-qt
          adwaita-qt6
          adwaita-icon-theme

          xdg-user-dirs
          xdg-user-dirs-gtk

          bash-completion
          bash-language-server

          vial
          blender
          discord
          firefox
          filezilla
          obs-studio
          cursor-cli

          pods
          lact
          coulr
          loupe
          snoop
          pinta
          packet
          papers
          baobab
          sysprof
          cartero
          decibels
          snapshot
          nautilus
          showtime
          resources
          typesetter
          impression
          gnome-maps
          gnome-clocks
          gnome-weather
          gnome-decoder
          gnome-console
          gnome-calendar
          gnome-calculator
          gnome-characters
          gnome-text-editor
          gnome-sound-recorder
        ];
      };

      services = {
        ssh-agent = {
          enable = true;
        };

        polkit-gnome = {
          enable = true;
        };

        wl-clip-persist = {
          enable = true;
          clipboardType = "regular";
        };
      };

      programs = {
        fzf.enable = true;
        zoxide.enable = true;
        home-manager.enable = true;

        direnv = {
          enable = true;
          nix-direnv.enable = true;
        };

        quickshell = {
          enable = true;
          activeConfig = "shell";
          configs.shell = ../shell;
          systemd.enable = true;
        };

        bash = {
          enable = true;

          shellAliases = {
            ls = "ls --color=auto --group-directories-first --sort=extension --human-readable";

            grep = "grep --color=auto";
            fgrep = "fgrep --color=auto";
            egrep = "egrep --color=auto";
            dir = "dir --color=auto";
            vdir = "vdir --color=auto";

            l = "ls -Al";
            la = "ls -A";
            ll = "ls -l";

            cp = "cp -iv";
            rm = "rm -i";
            mv = "mv -iv";

            cd = "z";
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
            "clear"
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
              PS1='\[\e[102m\] \[\e[1m\]\w\[\e[22m\] \[\e[0m\] '
            }

            PROMPT_COMMAND="set_prompt"
          '';
        };

        git = {
          enable = true;

          settings = {
            credential.helper = "store";
            fetch.recurseSubmodules = "on-demand";
            branch.sort = "-committerdate";
            tag.sort = "-taggerdate";
            init.defaultBranch = "main";
            color.ui = "auto";

            user = {
              name = "gael-lopes-da-silva";
              email = "gael.lopes-da-silva@outlook.fr";
            };

            push = {
              default = "current";
              followTags = true;
              autoSetupRemote = true;
            };

            pull = {
              default = "current";
              rebase = true;
            };

            rebase = {
              autoStash = true;
              missingCommitsCheck = "warn";
            };

            status = {
              branch = true;
              showStash = true;
              submoduleSummary = true;
              showUntrackedFiles = "all";
            };

            log = {
              abbrevCommit = true;
              follow = true;
              decorate = false;
            };

            core = {
              compression = 9;
              pager = "less";
              whitespace = "-trailing-space";
              preloadindex = true;
            };

            advice = {
              addEmptyPathspec = false;
              pushNonFastForward = false;
              statusHints = false;
            };

            diff = {
              context = 3;
              interHunkContext = 10;
              mnemonicPrefix = true;
              renames = true;
              submodule = "log";
            };

            grep = {
              break = true;
              heading = true;
              lineNumber = true;
            };

            rerere = {
              autoupdate = true;
              enabled = true;
            };

            alias = {
              prune = "fetch --prune";
              undo = "reset --soft HEAD^";
            };
          };
        };

        zed-editor = {
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
      };

      wayland.windowManager.niri = {
        enable = true;

        settings = {
          prefer-no-csd = { };
          screenshot-path = null;

          input = {
            mod-key = "Super";
            mod-key-nested = "Alt";

            keyboard.xkb = {
              layout = "us";
              variant = "intl";
            };

            touchpad = {
              tap = { };
              natural-scroll = { };
            };

            tablet = {
              map-to-focused-output = { };
            };

            focus-follows-mouse._props = {
              max-scroll-amount = "0%";
            };
          };

          layout = {
            gaps = 15;
            background-color = "transparent";
            center-focused-column = "never";
            empty-workspace-above-first = { };
            always-center-single-column = { };

            preset-column-widths._children = [
              { proportion = 0.5; }
              { proportion = 1.0; }
            ];

            preset-window-heights._children = [
              { proportion = 0.5; }
              { proportion = 1.0; }
            ];

            default-column-width._children = [
              { proportion = 1.0; }
            ];

            focus-ring.off = { };

            border = {
              on = { };
              width = 1;
              active-color = "#404040";
              inactive-color = "#303030";
            };

            tab-indicator = {
              off = { };
            };

            shadow = {
              on = { };
              softness = 4;
              spread = 2;
              color = "#00000070";
              inactive-color = "#00000054";
              offset._props = {
                x = 0;
                y = 2;
              };
            };
          };

          overview = {
            zoom = 0.75;
            backdrop-color = "transparent";

            workspace-shadow = {
              off = { };
            };
          };

          cursor = {
            xcursor-theme = "Bibata-Modern-Classic";
            xcursor-size = 24;
          };

          clipboard = {
            disable-primary = { };
          };

          hotkey-overlay = {
            skip-at-startup = { };
          };

          recent-windows = {
            off = { };
          };

          _children = [
            {
              window-rule._children = [
                { geometry-corner-radius = 12; }
                { clip-to-geometry = true; }
                { open-maximized-to-edges = false; }
                { open-maximized = false; }
                { open-fullscreen = false; }
              ];
            }
            {
              window-rule._children = [
                {
                  match._props = {
                    title = "^(Open|Save|Save As|Preferences|Settings)( .*)?$";
                  };
                }
                { open-floating = true; }
              ];
            }
            {
              layer-rule._children = [
                {
                  match._props = {
                    namespace = "^wallpaper$";
                  };
                }
                { place-within-backdrop = true; }
              ];
            }
          ];

          binds = {
            "Mod+Return" = {
              _props.repeat = false;
              spawn = [ "kgx" ];
            };
            "Mod+BackSpace" = {
              _props.repeat = false;
              spawn = [ "firefox" ];
            };

            "Mod+P" = {
              _props.repeat = false;
              spawn = [
                "qs"
                "-c"
                "shell"
                "ipc"
                "call"
                "launcher"
                "toggle"
              ];
            };
            "Mod+B" = {
              _props.repeat = false;
              spawn = [
                "qs"
                "-c"
                "shell"
                "ipc"
                "call"
                "interface"
                "toggle"
              ];
            };

            "XF86AudioRaiseVolume".spawn-sh = [
              "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"
            ];
            "XF86AudioLowerVolume".spawn-sh = [
              "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"
            ];
            "XF86AudioMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle" ];
            "XF86AudioMicMute".spawn-sh = [ "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle" ];

            "XF86AudioPlay".spawn-sh = [ "playerctl play-pause" ];
            "XF86AudioStop".spawn-sh = [ "playerctl stop" ];
            "XF86AudioPrev".spawn-sh = [ "playerctl previous" ];
            "XF86AudioNext".spawn-sh = [ "playerctl next" ];

            "XF86MonBrightnessUp".spawn-sh = [ "brightnessctl --class=backlight set +10%" ];
            "XF86MonBrightnessDown".spawn-sh = [ "brightnessctl --class=backlight set 10%-" ];

            "Mod+Left".focus-column-left = { };
            "Mod+Down".focus-window-down = { };
            "Mod+Up".focus-window-up = { };
            "Mod+Right".focus-column-right = { };
            "Mod+H".focus-column-left = { };
            "Mod+J".focus-window-down = { };
            "Mod+K".focus-window-up = { };
            "Mod+L".focus-column-right = { };

            "Mod+Ctrl+Left".move-column-left = { };
            "Mod+Ctrl+Down".move-window-down = { };
            "Mod+Ctrl+Up".move-window-up = { };
            "Mod+Ctrl+Right".move-column-right = { };
            "Mod+Ctrl+H".move-column-left = { };
            "Mod+Ctrl+J".move-window-down = { };
            "Mod+Ctrl+K".move-window-up = { };
            "Mod+Ctrl+L".move-column-right = { };

            "Mod+Home".focus-column-first = { };
            "Mod+End".focus-column-last = { };
            "Mod+Ctrl+Home".move-column-to-first = { };
            "Mod+Ctrl+End".move-column-to-last = { };

            "Mod+Shift+Left".focus-monitor-left = { };
            "Mod+Shift+Down".focus-monitor-down = { };
            "Mod+Shift+Up".focus-monitor-up = { };
            "Mod+Shift+Right".focus-monitor-right = { };
            "Mod+Shift+H".focus-monitor-left = { };
            "Mod+Shift+J".focus-monitor-down = { };
            "Mod+Shift+K".focus-monitor-up = { };
            "Mod+Shift+L".focus-monitor-right = { };

            "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = { };
            "Mod+Shift+Ctrl+H".move-column-to-monitor-left = { };
            "Mod+Shift+Ctrl+J".move-column-to-monitor-down = { };
            "Mod+Shift+Ctrl+K".move-column-to-monitor-up = { };
            "Mod+Shift+Ctrl+L".move-column-to-monitor-right = { };

            "Mod+Page_Down".focus-workspace-down = { };
            "Mod+Page_Up".focus-workspace-up = { };
            "Mod+U".focus-workspace-down = { };
            "Mod+I".focus-workspace-up = { };
            "Mod+Shift+Page_Down".move-workspace-down = { };
            "Mod+Shift+Page_Up".move-workspace-up = { };
            "Mod+Shift+U".move-workspace-down = { };
            "Mod+Shift+I".move-workspace-up = { };
            "Mod+Ctrl+Page_Down".move-column-to-workspace-down = { };
            "Mod+Ctrl+Page_Up".move-column-to-workspace-up = { };
            "Mod+Ctrl+U".move-column-to-workspace-down = { };
            "Mod+Ctrl+I".move-column-to-workspace-up = { };

            "Mod+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              focus-workspace-down = { };
            };
            "Mod+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              focus-workspace-up = { };
            };
            "Mod+Ctrl+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              move-column-to-workspace-down = { };
            };
            "Mod+Ctrl+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              move-column-to-workspace-up = { };
            };
            "Mod+WheelScrollRight" = {
              _props.cooldown-ms = 150;
              focus-column-right = { };
            };
            "Mod+WheelScrollLeft" = {
              _props.cooldown-ms = 150;
              focus-column-left = { };
            };
            "Mod+Ctrl+WheelScrollRight" = {
              _props.cooldown-ms = 150;
              move-column-right = { };
            };
            "Mod+Ctrl+WheelScrollLeft" = {
              _props.cooldown-ms = 150;
              move-column-left = { };
            };
            "Mod+Shift+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              focus-column-right = { };
            };
            "Mod+Shift+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              focus-column-left = { };
            };
            "Mod+Ctrl+Shift+WheelScrollDown" = {
              _props.cooldown-ms = 150;
              move-column-right = { };
            };
            "Mod+Ctrl+Shift+WheelScrollUp" = {
              _props.cooldown-ms = 150;
              move-column-left = { };
            };

            "Mod+O" = {
              _props.repeat = false;
              toggle-overview = { };
            };
            "Mod+Tab" = {
              _props.repeat = false;
              focus-workspace-previous = { };
            };

            "Mod+Shift+C" = {
              _props.repeat = false;
              close-window = { };
            };

            "Mod+R" = {
              _props.repeat = false;
              switch-preset-column-width = { };
            };
            "Mod+Shift+R" = {
              _props.repeat = false;
              switch-preset-window-height = { };
            };

            "Mod+BracketLeft" = {
              _props.repeat = false;
              consume-or-expel-window-left = { };
            };
            "Mod+BracketRight" = {
              _props.repeat = false;
              consume-or-expel-window-right = { };
            };
            "Mod+Comma" = {
              _props.repeat = false;
              consume-window-into-column = { };
            };
            "Mod+Period" = {
              _props.repeat = false;
              expel-window-from-column = { };
            };

            "Mod+F" = {
              _props.repeat = false;
              maximize-window-to-edges = { };
            };
            "Mod+Shift+F" = {
              _props.repeat = false;
              fullscreen-window = { };
            };

            "Mod+E" = {
              _props.repeat = false;
              center-column = { };
            };
            "Mod+Ctrl+E" = {
              _props.repeat = false;
              center-visible-columns = { };
            };

            "Mod+Minus".set-column-width = "-10%";
            "Mod+Equal".set-column-width = "+10%";
            "Mod+Shift+Minus".set-window-height = "-10%";
            "Mod+Shift+Equal".set-window-height = "+10%";

            "Mod+Space" = {
              _props.repeat = false;
              toggle-window-floating = { };
            };
            "Mod+Shift+Space" = {
              _props.repeat = false;
              switch-focus-between-floating-and-tiling = { };
            };

            "Mod+Print" = {
              _props.repeat = false;
              screenshot._props = {
                show-pointer = false;
              };
            };
            "Mod+Shift+Print" = {
              _props.repeat = false;
              screenshot-window._props = {
                show-pointer = false;
              };
            };
            "Mod+Ctrl+Print" = {
              _props.repeat = false;
              screenshot-screen._props = {
                show-pointer = false;
              };
            };

            "Mod+Escape" = {
              _props.allow-inhibiting = false;
              toggle-keyboard-shortcuts-inhibit = { };
            };
          };
        };
      };

      gtk = {
        enable = true;

        gtk3.extraConfig = {
          gtk-application-prefer-dark-theme = 1;
          gtk-error-bell = false;
        };

        gtk4.extraConfig = {
          gtk-error-bell = false;
        };
      };

      qt = {
        enable = true;

        platformTheme = {
          name = "adwaita";
        };

        style = {
          name = "adwaita-dark";
        };
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
          };
          "org/gnome/desktop/wm/preferences" = {
            button-layout = ":close";
          };
        };
      };

      xdg.portal = {
        enable = true;
        xdgOpenUsePortal = true;

        extraPortals = with pkgs; [
          xdg-desktop-portal-gnome
        ];

        config = {
          common = {
            default = [
              "gnome"
            ];
          };
        };
      };
    };
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
  };

  security = {
    protectKernelImage = true;
    rtkit.enable = true;
    polkit.enable = true;
  };

  virtualisation = {
    docker = {
      enable = false;

      rootless = {
        enable = true;
        setSocketVariable = true;

        daemon.settings = {
          dns = [
            "1.1.1.1"
            "8.8.8.8"
          ];
        };
      };
    };
  };
}
