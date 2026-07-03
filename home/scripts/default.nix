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

  power-menu = mkGtkApp "power-menu" ./menu/power_menu.py;
  macros-menu = mkGtkApp "macros-menu" ./menu/macros_menu.py;
  command-menu = mkGtkApp "command-menu" ./menu/command_menu.py;
  clipboard-menu = mkGtkApp "clipboard-menu" ./menu/clipboard_menu.py;
  soundboard-menu = mkGtkApp "soundboard-menu" ./menu/soundboard_menu.py;
  application-menu = mkGtkApp "application-menu" ./menu/application_menu.py;
in
{
  home.packages = [
    power-menu
    macros-menu
    command-menu
    clipboard-menu
    soundboard-menu
    application-menu
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

        "battery_notify.sh" = ./notify/battery_notify.sh;
        "datetime_notify.sh" = ./notify/datetime_notify.sh;

        "audio_monitor.sh" = ./monitor/audio_monitor.sh;
        "battery_monitor.sh" = ./monitor/battery_monitor.sh;
        "brightness_monitor.sh" = ./monitor/brightness_monitor.sh;
        "output_monitor.sh" = ./monitor/output_monitor.sh;
        "usb_monitor.sh" = ./monitor/usb_monitor.sh;

        "mute_process.sh" = ./utility/mute_process.sh;
        "freeze_process.sh" = ./utility/freeze_process.sh;
        "kill_process.sh" = ./utility/kill_process.sh;

        "soundboard_setup.sh" = ./utility/soundboard_setup.sh;
      };
}
