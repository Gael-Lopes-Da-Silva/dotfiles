{ pkgs, ... }:

{
  systemd = {
    oomd.enable = false;
  };

  services = {
    printing.enable = true;
    blueman.enable = true;
    gvfs.enable = true;
    lact.enable = true;

    earlyoom = {
      enable = true;
      enableNotifications = true;
    };

    udev = {
      packages = with pkgs; [
        via
        vial

        qmk
        qmk_hid
        qmk-udev-rules
      ];
    };

    logind = {
      settings = {
        Login.HandlePowerKey = "ignore";
      };
    };

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };
}
