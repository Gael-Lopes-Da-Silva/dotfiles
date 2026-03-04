{ config, pkgs, ... }:

{
  systemd.user.services = {
    battery_monitor = {
      Unit = {
        Description = "Battery OSD";
        After = [ "niri.service" ];
      };

      Service = {
        ExecStart = "${pkgs.bash}/bin/bash %h/.local/bin/battery_monitor.sh";
      };

      Install = {
        WantedBy = [ "default.target" ];
      };
    };
  };
}
