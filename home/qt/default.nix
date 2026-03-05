{ config, pkgs, ... }:

{
  qt = {
    enable = true;

    platformTheme = {
      name = "gnome";
    };

    style = {
      name = "adwaita-dark";
    };
  };
}
