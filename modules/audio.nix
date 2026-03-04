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
      pipewire."92-low-latency" = {
        "context.properties" = {
          "default.clock.rate" = 48000;
          "default.clock.quantum" = 128;
          "default.clock.min-quantum" = 64;
          "default.clock.max-quantum" = 256;
        };
      };

      pipewire."91-null-sinks" = {
        "context.objects" = [
          {
            factory = "adapter";
            args = {
              "factory.name"     = "support.null-audio-sink";
              "node.name"        = "SoundboardInput";
              "node.description" = "Soundboard Input";
              "media.class"      = "Audio/Sink";
              "audio.position"   = "FL,FR";
            };
          }
          {
            factory = "adapter";
            args = {
              "factory.name"     = "support.null-audio-sink";
              "node.name"        = "SoundboardOutput";
              "node.description" = "Soundboard Output";
              "media.class"      = "Audio/Source/Virtual";
              "audio.position"   = "FL,FR";
            };
          }
        ];
      };

      pipewire-pulse."92-low-latency" = {
        context.modules = [
          {
            name = "libpipewire-module-protocol-pulse";
            args = {
              pulse.min.req = "128/48000";
              pulse.default.req = "128/48000";
              pulse.max.req = "256/48000";
              pulse.min.quantum = "64/48000";
              pulse.max.quantum = "256/48000";
            };
          }
        ];
        stream.properties = {
          node.latency = "128/48000";
          resample.quality = 3;
        };
      };
    };
  };
}
