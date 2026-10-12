{ pkgs, ... }:

{
  home.packages = with pkgs; [
    wl-clipboard
  ];

  services.wl-clip-persist = {
    enable = true;
    clipboardType = "regular";
  };
}
