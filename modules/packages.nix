{ pkgs, ... }:

{
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-lgc-plus
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
    noto-fonts-color-emoji
    noto-fonts-monochrome-emoji

    nerd-fonts.symbols-only
  ];

  environment.systemPackages = with pkgs; [
    man-pages
    man-pages-posix
  ];

  programs = {
    niri.enable = true;
    nix-ld.enable = true;
    xwayland.enable = true;
    ydotool.enable = true;
  };
}
