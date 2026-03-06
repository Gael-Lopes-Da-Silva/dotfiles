{ ... }:

{
  services = {
    cliphist = {
      enable = true;
      allowImages = true;
    };
    wl-clip-persist = {
      enable = true;
      clipboardType = "regular";
    };
  };
}
