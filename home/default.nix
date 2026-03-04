{ config, pkgs, ... }:

{
  imports = [
    ./alacritty
    ./dunst
    ./git
    ./gtk
    ./niri
    ./nushell
    ./qt
    ./scripts
    ./zed
  ];

  home = {
    stateVersion = "25.11";
    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.cargo/bin"
    ];
  };

  services = {
    gnome-keyring.enable = true;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;

    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome
    ];

    config.common.default = [ "gtk" "gnome" ];
  };

  systemd.user.services.soundboard = {
    Unit = {
      Description = "Soundboard Setup";
      After = [ "pipewire.service" "pipewire-pulse.service" ];
      BindsTo = "pipewire.service";
      PartOf = "pipewire.service";
    };

    Service = {
      Type = "oneshot";
      ExecStart = "%h/.local/bin/soundboard_setup.sh";
      RemainAfterExit = true;
    };

    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  dconf.settings."org/gnome/desktop/interface".color-scheme = "prefer-dark";
}
