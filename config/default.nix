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

    initrd = {
      verbose = false;
    };

    consoleLogLevel = 3;

    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "v4l2loopback" ];
    kernelParams = [
      "quiet"
      "nowatchdog=1"
    ];

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
  };

  services = {
    gvfs = {
      enable = true;
    };

    lact = {
      enable = true;
    };

    displayManager.gdm = {
      enable = true;
    };

    desktopManager.gnome = {
      enable = true;
    };

    gnome = {
      core-apps.enable = false;
      core-developer-tools.enable = false;
      games.enable = false;
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

          "91-null-sinks" = {
            "context.objects" = [
              {
                factory = "adapter";
                args = {
                  "factory.name" = "support.null-audio-sink";
                  "node.name" = "SoundboardSink";
                  "node.description" = "Soundboard Speaker";
                  "media.class" = "Audio/Sink";
                  "audio.position" = "FL,FR";
                };
              }
              {
                factory = "adapter";
                args = {
                  "factory.name" = "support.null-audio-sink";
                  "node.name" = "SoundboardSource";
                  "node.description" = "Soundboard Mic";
                  "media.class" = "Audio/Source/Virtual";
                  "audio.position" = "FL,FR";
                };
              }
            ];
          };
        };
      };
    };
  };

  environment = {
    gnome.excludePackages = with pkgs; [
      gnome-tour
      gnome-user-docs
    ];

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
    defaultLocale = "en_US.UTF-8";
    defaultCharset = "UTF-8";
  };

  users = {
    users.gael = {
      isNormalUser = true;
      extraGroups = [
        "kvm"
        "disk"
        "input"
        "wheel"
        "audio"
        "video"
        "uinput"
        "libvirtd"
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

        packages = with pkgs; [
          gtk3
          gtk4
          glib
          adwaita-qt
          adwaita-qt6
          adwaita-icon-theme
          libsecret
          libnotify
          pulseaudio
          wl-clipboard
          xdg-user-dirs
          xdg-user-dirs-gtk
          bash-completion
          bash-language-server
          nil
          nixd

          vial
          blender
          discord
          firefox
          filezilla
          obs-studio
          cursor-cli

          # pods
          # lact
          # coulr
          # loupe
          # snoop
          # pinta
          # packet
          # papers
          # baobab
          # cartero
          # decibels
          # snapshot
          # nautilus
          # showtime
          # resources
          # impression
          # gnome-maps
          # gnome-clocks
          # gnome-weather
          # gnome-decoder
          # gnome-console
          # gnome-calendar
          # gnome-calculator
          # gnome-characters
          # gnome-text-editor
          # gnome-sound-recorder
        ];
      };

      services = {
        wl-clip-persist = {
          enable = true;
          clipboardType = "regular";
        };
      };

      programs = {
        home-manager.enable = true;
        zoxide.enable = true;
        fzf.enable = true;

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
        platformTheme = "gnome";
        style = "adwaita-dark";
      };

      dconf = {
        enable = true;
        settings = {
          "org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            enable-hot-corners = false;
          };

          "org/gnome/desktop/wm/preferences" = {
            button-layout = ":close";
            workspace-names = [ "Main" ];
          };

          "org/gnome/desktop/background" = {
            picture-uri = "";
            picture-uri-dark = "";
            show-desktop-icons = true;
          };

          "org/gnome/desktop/screensaver" = {
            picture-uri = "";
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

    libvirtd = {
      enable = true;
      qemu.swtpm.enable = true;
    };

    spiceUSBRedirection = {
      enable = true;
    };
  };
}
