{ pkgs, ... }:

{
  services = {
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

    openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = true;
        PermitRootLogin = "no";
      };
    };
  };
}
