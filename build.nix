{
  pkgs,
  stdenv,
  pkgsCross,
  fetchurl,
  unzip,
  writeTextDir,
}:
with stdenv;
let
  configDir = "/var/lib/ngrok";
  releases = builtins.fromJSON (builtins.readFile ./releases.json);
  version = releases.version;
  ngrokDrv =
    { sha256, url }:
    stdenv.mkDerivation {
      name = "ngrok-${version}";
      version = version;
      src = fetchurl { inherit sha256 url; };
      sourceRoot = ".";
      unpackPhase = "${unzip}/bin/unzip $src ngrok";
      buildPhase = "chmod a+x ngrok";
      installPhase = ''
        install -D ngrok $out/bin/ngrok
      '';
    };
  ngrokBinArm = ngrokDrv releases.arm;
  ngrokBinAmd64 = ngrokDrv releases.amd64;
  ngrokBinArm64 = ngrokDrv releases.arm64;
  ngrokBini386 = ngrokDrv releases.i386;
  shadowSetup = [
    (writeTextDir "etc/shadow" ''
      root:!x:::::::
      ngrok:!:::::::
    '')
    (writeTextDir "etc/passwd" ''
      root:x:0:0::/root:/bin/bash
      ngrok:x:1000:100::/home/ngrok:
    '')
    (writeTextDir "etc/group" ''
      root:x:0:
      ngrok:x:100:
    '')
    (writeTextDir "etc/gshadow" ''
      root:x::
      ngrok:x::
    '')
  ];
  entrypoint = ./scripts;
  extraCommands = ''
    mkdir -p .${configDir}
    chmod a+rw -R .${configDir}
    echo "version: 3" > .${configDir}/ngrok.yml
    echo "agent:" >> .${configDir}/ngrok.yml
    echo "    web_addr: 0.0.0.0:4040" >> .${configDir}/ngrok.yml
  '';
in
rec {
  debianArm64 = import ./debian.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    imageSha256 = "sha256-Jlun6tavsH3VC+GcKhXpj90B7widvB3KAprFe0HR3hg=";
    imageDigest = "sha256:b8dee49b29a16c89f0781356ccb07cbf6c5195dace2e6e1b6a42f4c9af1e55fa";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm64 = import ./alpine.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    imageSha256 = "sha256-YK+b0j8kWYEa6AyFWI833TbqddFxWiPCF499dNdnOI8=";
    imageDigest = "sha256:5dda816445facf5f7282dc7689a333278834c74265ba25db2e2eb90509e3a9dd";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debianAmd64 = import ./debian.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageSha256 = "sha256-W9e/m+v8CFpttJa9tNXmqwRVAPxDertSh2AInPOFsPg=";
    imageDigest = "sha256:366a6da5efcceffbaa19c560a101b97b87a1a9664eeeac8bc3d24395ddbf14f3";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  alpineAmd64 = import ./alpine.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageDigest = "sha256:644c1ad8fc45cc581ab1b5ea7ec1bebc9b037fd4801ad697ca124deb3f9c9332";
    imageSha256 = "sha256-DT8KqBF8gCUehPICE1HhKceHbSZIM69p5FvuJn5YiGk=";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  debianArm = import ./debian.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "sha256-XVBKy5hSSyHs1VUa6YFm6iSnYlkYIxyObElGW8QQAWg=";
    imageDigest = "sha256:c32b4b14fef059f242fe317da56fd06ccbe2f9c6e72110cb1c38b9c716ceeb31";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm = import ./alpine.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "sha256-+oLAg/MJHYMJYBsn1v8xh0tPX+CJVshuFRwqX7+mWxs=";
    imageDigest = "sha256:a69938a920926e3ddb659f68a1432d1bcda694b411e4352b1e7a16aff20f5f05";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debian386 = import ./debian.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "sha256-TLKN4FDy78yOucltXTeKRBooj6IUxbP/bNRy1XYZ5lE=";
    imageDigest = "sha256:1deba4ebcaba43863facc728ad3cc49a62626f7545940b4ae93104f14e2f81f9";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpine386 = import ./alpine.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "sha256-lXM08g4vwMeUliMHMH4QjBZunlZQlKQyG0d8RQa0WcE=";
    imageDigest = "sha256:e1811e759db73e07a7df4e7c667fe39a90166e5a4c66a3c22eb40bbb1031194a";
    inherit extraCommands entrypoint shadowSetup version;
  };
}
