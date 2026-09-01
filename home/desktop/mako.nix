{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      layer = "overlay";
      default-timeout = 5000;
      text-color = "#ffffffff";
      background-color = "#0D0D0Dff";
      border-size = 1;
      border-color = "#404040ff";
      border-radius = 10;
      progress-color = "#242424ff";
      margin = 2;
      padding = 10;
      outer-margin = 14;

      "app-name=osd".anchor = "bottom-center";
      "app-name=notification".anchor = "top-right";
    };
  };
}
