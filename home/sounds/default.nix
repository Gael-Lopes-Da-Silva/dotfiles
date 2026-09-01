{ pkgs, ... }:

let
  inherit (pkgs.lib)
    mapAttrs
    mapAttrs'
    filterAttrs
    any
    hasSuffix
    ;

  soundsDir = ./.;
  audioExtensions = [
    ".mp3"
    ".wav"
    ".ogg"
    ".flac"
    ".opus"
    ".aac"
  ];

  isAudioFile = name: type: type == "regular" && any (ext: hasSuffix ext name) audioExtensions;

  soundFiles = mapAttrs (name: _: soundsDir + "/${name}") (
    filterAttrs isAudioFile (builtins.readDir soundsDir)
  );
in
{
  home.file = mapAttrs' (filename: srcPath: {
    name = ".local/sounds/${filename}";
    value = {
      source = srcPath;
    };
  }) soundFiles;
}
