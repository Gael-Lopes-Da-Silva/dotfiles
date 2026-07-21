{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      layer = "overlay";
      default-timeout = 5000;
      text-color = "#ffffffff";
      background-color = "#0D0D0Dff";
      border-size = 6;
      border-color = "#3B3B3Bff";
      border-radius = 10;
      progress-color = "#242424ff";
      margin = 2;
      padding = 8;
      outer-margin = 20;

      "app-name=osd".anchor = "bottom-center";
      "app-name=notification".anchor = "top-right";
    };
  };
}
