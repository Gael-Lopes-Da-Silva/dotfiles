{ config, pkgs, ... }:

{
  fonts.packages = with pkgs; [
    # Noto families
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    # Symbols
    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    # Wayland / Desktop
    xwayland-satellite
    wl-clipboard
    wl-clip-persist
    cliphist
    brightnessctl

    # Core Utilities
    p7zip
    ouch
    xdg-user-dirs
    xdg-user-dirs-gtk

    # Desktop Integration
    udiskie

    # Sandboxing
    wine
    wine-wayland
    winetricks
  ];

  services = {
    xserver.enable = false;
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
    pulseaudio.enable = true;

    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
      wireplumber.enable = true;
    };

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
