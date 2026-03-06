{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;

    profiles = {
      laptop_undocked = {
        outputs = [
          {
            criteria = "eDP-1";
            mode = "1920x1080@60Hz";
            scale = 1.0;
            status = "enable";
          }
        ];
      };
      laptop_docked = {
        outputs = [
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
      };
      desktop = {
        outputs = [
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
      };
    };
  };
}
