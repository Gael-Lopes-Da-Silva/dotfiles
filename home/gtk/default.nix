{ pkgs, ... }:

{
  home.packages = with pkgs; [
    gtk3
    gtk4
    glib
  ];

  gtk = {
    enable = true;

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-error-bell = false;
    };

    gtk4.extraConfig = {
      gtk-application-prefer-dark-theme = 1;
      gtk-error-bell = false;
    };
  };
}
