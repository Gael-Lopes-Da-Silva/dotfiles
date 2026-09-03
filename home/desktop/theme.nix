{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gtk3
    gtk4
    glib
    adwaita-qt
    adwaita-qt6
    adwaita-icon-theme
  ];

  home.pointerCursor = {
    enable = true;
    gtk.enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
  };

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-error-bell = false;
    };

    gtk4.extraConfig = {
      gtk-error-bell = false;
    };
  };

  qt = {
    enable = true;

    platformTheme = {
      name = "adwaita";
    };

    style = {
      name = "adwaita-dark";
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface".color-scheme = "prefer-dark";
    "org/gnome/desktop/wm/preferences".button-layout = ":close";
  };
}
