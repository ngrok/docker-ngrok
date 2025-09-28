{
  pkgs,
  arch,
  entrypoint,
  ngrokBin,
  shadowSetup,
  extraCommands,
  version,
  imageDigest,
  imageSha256,
}:

with pkgs;
let
  debianStable =
    { sha256, imageDigest }:
    dockerTools.pullImage {
      inherit arch sha256 imageDigest;
      imageName = "debian";
      os = "linux";
      finalImageName = "debian";
      finalImageTag = "bookworm";
    };
in
dockerTools.buildLayeredImage {
  inherit extraCommands;
  name = "ngrok/ngrok";
  tag = "${version}-debian-${arch}";
  fromImage = debianStable {
    sha256 = imageSha256;
    inherit imageDigest;
  };

  contents = [
    ngrokBin
    entrypoint
    pkgs.cacert
  ] ++ shadowSetup;
  config = {
    ExposedPorts = {
      "4040" = { };
    };
    Entrypoint = [ "${entrypoint}/entrypoint.sh" ];
    User = "ngrok";
  };
}
