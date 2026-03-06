{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;

    settings = [
      {
        profile.name = "laptop_undocked";

        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            scale = 1.0;
            status = "enable";
          }
        ];
      }
      {
        profile.name = "laptop_docked";

        profile.outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            position = "0,1080";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080@60Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
          }
        ];
      }
      {
        profile.name = "desktop";

        profile.outputs = [
          {
            criteria = "HDMI-A-1";
            mode = "1920x1080@100Hz";
            position = "0,1080";
            scale = 1.0;
            status = "enable";
          }
          {
            criteria = "HDMI-A-2";
            mode = "1920x1080@60Hz";
            position = "0,0";
            scale = 1.0;
            status = "enable";
          }
        ];
      }
    ];
  };
}
