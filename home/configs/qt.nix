{ pkgs, ... }:

{
  home.packages = with pkgs; [
    adwaita-qt
    adwaita-qt6
  ];

  qt = {
    enable = true;

    platformTheme = {
      name = "adwaita";
    };

    style = {
      name = "adwaita-dark";
    };
  };
}
