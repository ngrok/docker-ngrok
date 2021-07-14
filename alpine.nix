{ pkgs, arch, entrypoint, ngrokBin, shadowSetup, extraCommands, version
, imageDigest, imageSha256 }:

with pkgs;
let
  alpine = { imageDigest, sha256 }:
    dockerTools.pullImage {
      inherit arch imageDigest sha256;
      imageName = "alpine";
      os = "linux";
      finalImageName = "alpine";
      finalImageTag = "3.14.0";
    };
in dockerTools.buildLayeredImage {
  inherit extraCommands;
  name = "ngrok/ngrok";
  tag = "${version}-alpine-${arch}";
  fromImage = alpine {
    sha256 = imageSha256;
    inherit imageDigest;
  };
  contents = [ ngrokBin entrypoint ] ++ shadowSetup;
  config = {
    ExposedPorts = { "4040" = { }; };
    Entrypoint = [ "${entrypoint}/entrypoint.sh" ];
    User = "ngrok";
  };
}
