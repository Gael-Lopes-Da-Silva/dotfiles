{ pkgs, ... }:

{
  home.pointerCursor = {
    gtk.enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
  };

  gtk = {
    enable = true;

    theme = {
      name = "Adwaita-dark";
    };
  };
}
