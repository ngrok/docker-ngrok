{ pkgs, arch, entrypoint, ngrokBin, shadowSetup, extraCommands }:

with pkgs;
let
  alpine = dockerTools.pullImage {
    inherit arch;
    imageName = "alpine";
    # alpine 3.13.5 on 6/11/21
    imageDigest =
      "sha256:def822f9851ca422481ec6fee59a9966f12b351c62ccb9aca841526ffaa9f748";
    os = "linux";
    sha256 = "0g5jh5bqg0hxs5f6vazpfnfbbd1hjj7rczizyxxzrcifvcgfys09";
    finalImageName = "alpine";
    finalImageTag = "3.13.5";
  };
in dockerTools.buildLayeredImage {
  inherit extraCommands;
  name = "ngrok";
  tag = "alpine-2.3.40-${arch}";
  fromImage = alpine;
  contents = [ ngrokBin entrypoint ] ++ shadowSetup;
  config = {
    ExposedPorts = { "4040" = { }; };
    Entrypoint = [ "${entrypoint}/entrypoint.sh" ];
    User = "ngrok";
  };
}
