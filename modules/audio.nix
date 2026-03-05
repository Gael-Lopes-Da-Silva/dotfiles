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
      pipewire."91-null-sinks" = {
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
}
