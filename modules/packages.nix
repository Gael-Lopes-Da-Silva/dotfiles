{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    terminus_font

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    niri
    gtk3
    gtk4
    qt5.qtwayland
    qt6.qtwayland
    xdg-desktop-portal
    xdg-desktop-portal-gtk
    xdg-desktop-portal-gnome
    xwayland-satellite

    git
    fzf
    neovim
    firefox
    alacritty
    zed-editor
    ouch
    p7zip
    wl-clipboard
    brightnessctl
    playerctl
    dunst
    udiskie
    gvfs
    wine
    winetricks
    termscp

    python3
    bun
    php
    composer
    rustc
    cargo
    rust-analyzer
    clippy
    rustfmt

    docker-compose
    bash-completion
  ];

  programs = {
    firefox.enable = true;
    niri.enable = true;

  #   bash = {
  #     enable = true;

  #     historySize = 10000;
  #     historyFileSize = 20000;
  #     historyControl = [ "ignoreboth" ];

  #     shellAliases = {
  #       grep = "grep --color=auto";
  #       fgrep = "fgrep --color=auto";
  #       egrep = "egrep --color=auto";
  #       dir = "dir --color=auto";
  #       vdir = "vdir --color=auto";

  #       ls = "ls --color=auto --sort=extension --group-directories-first";
  #       la = "ls -Alh";
  #       ll = "ls -lh";

  #       cp = "cp -iprv";
  #       rm = "rm -rIdv";
  #       mv = "mv -iv";

  #       compress = "ouch compress";
  #       decompress = "ouch decompress";
  #     };

  #     initExtra = ''
  #       shopt -s checkwinsize histappend autocd dirspell cdspell cmdhist globstar extglob

  #       bind 'set show-all-if-ambiguous on'
  #       bind 'set mark-symlinked-directories on'
  #       bind 'set completion-ignore-case on'
  #       bind 'set colored-stats on'
  #       bind 'set enable-bracketed-paste off'

  #       bind 'TAB:menu-complete'
  #       bind '"\e[Z":menu-complete-backward'
  #       bind '"\e[A":history-search-backward'
  #       bind '"\e[B":history-search-forward'

  #       RESET="\[\e[0m\]"
  #       GREEN="\[\e[92;1m\]"
  #       RED="\[\e[91;1m\]"

  #       get_prompt() {
  #         if [ "$?" -eq 0 ]; then
  #           PS1="$\{GREEN}\w$\{RESET}\n"
  #         else
  #           PS1="$\{RED}\w$\{RESET}\n"
  #         fi
  #       }

  #       PROMPT_COMMAND=get_prompt
  #     '';
  #   };
  };
}
