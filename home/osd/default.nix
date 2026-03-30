{ ... }:

{
  services = {
    swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        layer-shell = true;
      };
    };
    swayosd = {
      enable = true;
    };
  };
}
