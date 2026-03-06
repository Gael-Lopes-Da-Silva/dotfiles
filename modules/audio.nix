{ config, pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    audio.enable = true;
    wireplumber.enable = true;

    extraConfig = {
      pipewire = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 2048;
          "default.clock.min-quantum" = 2048;
          "default.clock.max-quantum" = 8192;
        };

        "91-null-sinks" = {
          "context.objects" = [
            {
              factory = "adapter";
              args = {
                "factory.name"     = "support.null-audio-sink";
                "node.name"        = "SoundboardSink";
                "node.description" = "Soundboard Speaker";
                "media.class"      = "Audio/Sink";
                "audio.position"   = "FL,FR";
              };
            }
            {
              factory = "adapter";
              args = {
                "factory.name"     = "support.null-audio-sink";
                "node.name"        = "SoundboardSource";
                "node.description" = "Soundboard Mic";
                "media.class"      = "Audio/Source/Virtual";
                "audio.position"   = "FL,FR";
              };
            }
          ];
        };
      };
    };
  };
}
