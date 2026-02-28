{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
    ./configs.nix
    ./packages.nix
  ];

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  boot.kernelModules = [ "v4l2loopback" ];

  boot.extraModulePackages = with config.boot.kernelPackages; [
    v4l2loopback
  ];

  services.emptty = {
    enable = true;
    settings = {
      tty = "/dev/tty1";
    };
  };

  console.font = "ter-132n";

  time.timeZone = "Europe/Paris";
  i18n.defaultLocale = "en_US.UTF-8";
  services.xserver.enable = false;

  virtualisation.docker.enable = true;

  fonts.packages = with pkgs; [
    terminus_font

    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji

    nerd-fonts.symbols-only
  ];

  system.stateVersion = "24.11";
}
