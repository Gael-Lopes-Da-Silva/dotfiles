{ pkgs, ... }:

{
  imports = [ ./monitor.nix ];

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

        "kill_process.sh" = ./utility/kill_process.sh;
        "freeze_process.sh" = ./utility/freeze_process.sh;
        "soundboard_setup.sh" = ./utility/soundboard_setup.sh;

        "active_workspace.sh" = ./events/active_workspace.sh;
        "screenshare_state.sh" = ./events/screenshare_state.sh;
      };
}
