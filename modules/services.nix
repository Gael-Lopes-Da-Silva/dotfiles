{ pkgs, ... }:

{
  services = {
    printing.enable = true;
    gvfs.enable = true;
    lact.enable = true;

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
