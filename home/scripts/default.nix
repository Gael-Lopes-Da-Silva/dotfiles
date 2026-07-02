{ pkgs, ... }:

let
  applicationMenu = pkgs.python3Packages.buildPythonApplication {
    pname = "application-menu";
    version = "1.0.0";
    format = "other";

    src = ./menu/application_menu.py;
    dontUnpack = true;

    nativeBuildInputs = with pkgs; [
      gobject-introspection
      wrapGAppsHook4
    ];

    buildInputs = with pkgs; [
      gtk4
      libadwaita
    ];

    propagatedBuildInputs = with pkgs.python3Packages; [
      pygobject3
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp ${./menu/application_menu.py} $out/bin/application-menu
      chmod +x $out/bin/application-menu
    '';
  };
in
{
  programs.fzf = {
    enable = true;
  };

  home.packages = [
    applicationMenu
  ];

  home.file.".local/bin/autostart.sh".source = ./autostart.sh;

  # home.file.".local/bin/application_menu.sh".source = ./menu/application_menu.sh;
  home.file.".local/bin/cliphist_menu.sh".source = ./menu/cliphist_menu.sh;
  home.file.".local/bin/command_menu.sh".source = ./menu/command_menu.sh;
  home.file.".local/bin/power_menu.sh".source = ./menu/power_menu.sh;
  home.file.".local/bin/soundboard_menu.sh".source = ./menu/soundboard_menu.sh;

  home.file.".local/bin/battery_notify.sh".source = ./notify/battery_notify.sh;
  home.file.".local/bin/datetime_notify.sh".source = ./notify/datetime_notify.sh;

  home.file.".local/bin/audio_monitor.sh".source = ./monitor/audio_monitor.sh;
  home.file.".local/bin/battery_monitor.sh".source = ./monitor/battery_monitor.sh;
  home.file.".local/bin/brightness_monitor.sh".source = ./monitor/brightness_monitor.sh;
  home.file.".local/bin/output_monitor.sh".source = ./monitor/output_monitor.sh;
  home.file.".local/bin/usb_monitor.sh".source = ./monitor/usb_monitor.sh;

  home.file.".local/bin/auto_click.sh".source = ./utility/auto_click.sh;
  home.file.".local/bin/mute_process.sh".source = ./utility/mute_process.sh;
  home.file.".local/bin/freeze_process.sh".source = ./utility/freeze_process.sh;
  home.file.".local/bin/kill_process.sh".source = ./utility/kill_process.sh;
  home.file.".local/bin/soundboard_setup.sh".source = ./utility/soundboard_setup.sh;
}
