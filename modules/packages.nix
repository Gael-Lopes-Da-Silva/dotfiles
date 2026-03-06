{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    ouch
    wine
    p7zip
    udiskie
    filezilla
    pulseaudio
    winetricks
    wine-wayland
    brightnessctl
    xdg-user-dirs
    xdg-user-dirs-gtk
    xwayland-satellite
  ];

  services = {
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };

    displayManager.ly = {
      enable = true;

      settings = {
        animation = "colormix";
        session_log = ".cache/ly/session.log";
        clock = "%d-%m-%Y %H:%M:%S";
        bigclock = true;
        blank_password = true;
        blank_box = true;
        hide_borders = false;
        hide_key_hints = true;
        load = true;
        save = true;
      };
    };
  };

  programs = {
    niri.enable = true;
    firefox.enable = true;
    xwayland.enable = true;
    firejail.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
