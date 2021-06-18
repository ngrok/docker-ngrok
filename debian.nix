{ pkgs, arch, entrypoint, ngrokBin, shadowSetup, extraCommands, version }:

with pkgs;
let
  debianBuster = dockerTools.pullImage {
    inherit arch;
    imageName = "debian";
    # debian:buster at 2021-05-19
    imageDigest =
      "sha256:acf7795dc91df17e10effee064bd229580a9c34213b4dba578d64768af5d8c51";
    os = "linux";
    sha256 = "1y7zgqjf6mypzg0yv23g7h74rs77x2kq5xmfkyb5cykq7rzi2b7b";
    finalImageName = "debian";
    finalImageTag = "buster";
  };
in dockerTools.buildLayeredImage {
  inherit extraCommands;
  name = "ngrok/ngrok";
  tag = "${version}-debian-${arch}";
  fromImage = debianBuster;
  contents = [ ngrokBin entrypoint ] ++ shadowSetup;
  config = {
    ExposedPorts = { "4040" = { }; };
    Entrypoint = [ "${entrypoint}/entrypoint.sh" ];
    User = "ngrok";
  };
}
