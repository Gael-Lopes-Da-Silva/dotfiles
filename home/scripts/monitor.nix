{ config, pkgs, ... }:

let
  monitorScript = name: "${config.home.homeDirectory}/.local/bin/${name}.sh";

  monitorService = name: {
    Unit = {
      Description = "${name} OSD monitor";
      After = [
        "graphical-session.target"
        "pipewire-pulse.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.bash}/bin/bash ${monitorScript name}";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  monitorServiceWithConditions =
    name: conditions:
    let
      service = monitorService name;
    in
    service
    // {
      Unit = service.Unit // conditions;
    };
in
{
  systemd.user.services = {
    audio-monitor = monitorService "audio_monitor";
    output-monitor = monitorService "output_monitor";
    usb-monitor = monitorService "usb_monitor";

    battery-monitor = monitorServiceWithConditions "battery_monitor" {
      ConditionPathExistsGlob = "/sys/class/power_supply/BAT*";
    };

    brightness-monitor = monitorServiceWithConditions "brightness_monitor" {
      ConditionPathExistsGlob = "/sys/class/backlight/*";
    };
  };
}
