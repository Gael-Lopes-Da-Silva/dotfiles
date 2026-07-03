{ pkgs, ... }:

let
  mkGtkApp =
    name: scriptPath:
    pkgs.python3Packages.buildPythonApplication {
      pname = name;
      version = "1.0.0";
      format = "other";

      src = scriptPath;
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
        cp ${scriptPath} $out/bin/${name}
        chmod +x $out/bin/${name}
      '';
    };

  application-menu = mkGtkApp "application-menu" ./menu/application_menu.py;
  command-menu = mkGtkApp "command-menu" ./menu/command_menu.py;
  clipboard-menu = mkGtkApp "clipboard-menu" ./menu/clipboard_menu.py;
in
{
  programs.fzf.enable = true;

  home.packages = [
    application-menu
    command-menu
    clipboard-menu
  ];

  home.file =
    pkgs.lib.mapAttrs'
      (filename: srcPath: {
        name = ".local/bin/${filename}";
        value = {
          source = srcPath;
        };
      })
      {
        "autostart.sh" = ./autostart.sh;

        "cliphist_menu.sh" = ./menu/cliphist_menu.sh;
        "power_menu.sh" = ./menu/power_menu.sh;
        "soundboard_menu.sh" = ./menu/soundboard_menu.sh;

        "battery_notify.sh" = ./notify/battery_notify.sh;
        "datetime_notify.sh" = ./notify/datetime_notify.sh;

        "audio_monitor.sh" = ./monitor/audio_monitor.sh;
        "battery_monitor.sh" = ./monitor/battery_monitor.sh;
        "brightness_monitor.sh" = ./monitor/brightness_monitor.sh;
        "output_monitor.sh" = ./monitor/output_monitor.sh;
        "usb_monitor.sh" = ./monitor/usb_monitor.sh;

        "auto_click.sh" = ./utility/auto_click.sh;
        "mute_process.sh" = ./utility/mute_process.sh;
        "freeze_process.sh" = ./utility/freeze_process.sh;
        "kill_process.sh" = ./utility/kill_process.sh;
        "soundboard_setup.sh" = ./utility/soundboard_setup.sh;
      };
}
