{ ... }:

{
  programs.fzf = {
    enable = true;
  };

  home.file.".local/bin/application_menu.sh".source = ./menu/application_menu.sh;
  home.file.".local/bin/cliphist_menu.sh".source = ./menu/cliphist_menu.sh;
  home.file.".local/bin/command_menu.sh".source = ./menu/command_menu.sh;
  home.file.".local/bin/power_menu.sh".source = ./menu/power_menu.sh;
  home.file.".local/bin/soundboard_menu.sh".source = ./menu/soundboard_menu.sh;

  home.file.".local/bin/battery_notify.sh".source = ./notify/battery_notify.sh;
  home.file.".local/bin/datetime_notify.sh".source = ./notify/datetime_notify.sh;
  home.file.".local/bin/workspace_notify.sh".source = ./notify/workspace_notify.sh;

  home.file.".local/bin/audio_monitor.sh".source = ./monitor/audio_monitor.sh;
  home.file.".local/bin/battery_monitor.sh".source = ./monitor/battery_monitor.sh;
  home.file.".local/bin/brightness_monitor.sh".source = ./monitor/brightness_monitor.sh;
  home.file.".local/bin/output_monitor.sh".source = ./monitor/output_monitor.sh;

  home.file.".local/bin/input_tool.sh".source = ./utility/input_tool.sh;
  home.file.".local/bin/mute_process.sh".source = ./utility/mute_process.sh;
  home.file.".local/bin/freeze_process.sh".source = ./utility/freeze_process.sh;
  home.file.".local/bin/kill_process.sh".source = ./utility/kill_process.sh;
  home.file.".local/bin/pick_color.sh".source = ./utility/pick_color.sh;
  home.file.".local/bin/soundboard_setup.sh".source = ./utility/soundboard_setup.sh;
}
