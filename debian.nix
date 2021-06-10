{ pkgs, entrypoint, ngrokBin, shadowSetup, extraCommands }:

with pkgs;
let
  debianBuster = dockerTools.pullImage {
    imageName = "debian";
    # debian:buster at 2021-05-19
    imageDigest =
      "sha256:acf7795dc91df17e10effee064bd229580a9c34213b4dba578d64768af5d8c51";
    os = "linux";
    arch = "amd64";
    sha256 = "1y7zgqjf6mypzg0yv23g7h74rs77x2kq5xmfkyb5cykq7rzi2b7b";
    finalImageName = "debian";
    finalImageTag = "buster";
  };
in dockerTools.buildLayeredImage {
  name = "ngrok";
  tag = "debian-2.3.40";
  fromImage = debianBuster;
  contents = [ ngrokBin (writeScriptBin "entrypoint.sh" entrypoint) ]
    ++ shadowSetup;
  extraCommands = extraCommands;
  config = {
    ExposedPorts = { "4040" = { }; };
    Entrypoint = [ "entrypoint.sh" ];
    User = "ngrok";
  };
}
