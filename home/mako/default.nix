{ ... }:

{
  services.mako = {
    enable = true;

    settings = {
      layer = "overlay";
      anchor = "top-right";
      default-timeout = 5000;
      text-color = "#ffffffff";
      background-color = "#060d0fff";
      border-size = 6;
      border-color = "#3B3B3Bff";
      border-radius = 12;
      progress-color = "#242424ff";
      margin = 2;
      padding = 8;
      outer-margin = 20;

      "app-name=volume" = {
        anchor = "bottom-center";
      };
      "app-name=microphone" = {
        anchor = "bottom-center";
      };
      "app-name=power" = {
        anchor = "bottom-center";
      };
      "app-name=battery" = {
        anchor = "bottom-center";
      };
      "app-name=brightness" = {
        anchor = "bottom-center";
      };
      "app-name=monitor" = {
        anchor = "bottom-center";
      };
    };
  };
}
