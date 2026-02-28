{ config, pkgs, ... }:

{
  services.displayManager.emptty.enable = true;

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = false;

  programs.bash.enable = true;
  programs.niri.enable = true;

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
    nerd-fonts.symbols-only
  ];
}
