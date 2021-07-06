{ pkgs, arch, entrypoint, ngrokBin, shadowSetup, extraCommands, version }:

with pkgs;
let
  debianBuster = dockerTools.pullImage {
    inherit arch;
    imageName = "debian";
    # debian:buster at 2021-07-06
    imageDigest =
      "sha256:5625c115ad881f19967a9b66416f8d40710bb307ad607d037f8ad8289260f75f";
    os = "linux";
    sha256 = "1rqvk4zhxx7xi5gqzwdz5f36s40avan4fbimkfbvg2jq8i0jqnd5";
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
