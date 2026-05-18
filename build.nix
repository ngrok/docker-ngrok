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
    imageSha256 = "0q569s2dbgqzckvdpmf6qppqxqdis6l2g7qz14vhxq29hqzbw1hd";
    imageDigest = "sha256:53692cdc49e2b0abdd9adf36466b366aaebdbbdbb2e6a7f432e2b4fb7327fd93";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm64 = import ./alpine.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    imageSha256 = "sha256-+Uk4ueQVlh4CXtClJgmcfGSeGAGMkEv8rKgXdCIz/HM=";
    imageDigest = "sha256:378c4c5418f7493bd500ad21ffb43818d0689daaad43e3261859fb417d1481a0";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debianAmd64 = import ./debian.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageSha256 = "1jf3hq38l7ca087whvj1pg82dyqm62fz83mrkq6gfnfr8am0wx2z";
    imageDigest = "sha256:3f03ff2fca74e47cee05599e36e1f1258d386895a3394b3683df333f404f4e8a";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  alpineAmd64 = import ./alpine.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageDigest = "sha256:4d889c14e7d5a73929ab00be2ef8ff22437e7cbc545931e52554a7b00e123d8b";
    imageSha256 = "sha256-/vu9AOd/0neZw5qECn3s0Ybi6NMdYDX49yaGELQjny0=";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  debianArm = import ./debian.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "10xgf8nb482qpxv16k9aaa06y5ahh99w5bcxywfv7wnp2as1di0p";
    imageDigest = "sha256:30c1b3317f599c1843157fb240ddbf4eafbccc70f6dbd7ba29dc1f7452309dd1";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm = import ./alpine.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "sha256-Gygl1eozOmQ/o4eNn2AYGjnbwx/jSw2baPshTwZloXM=";
    imageDigest = "sha256:0be3c29c7b8d475f38f71ac3d25eb5eb673c68cc673576996cb2afd7a536829a";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debian386 = import ./debian.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "0rgzkk0f73j7czcxddxzzzj163k7ki034hcjw4dgfskq14k2nrfk";
    imageDigest = "sha256:82c5ce38c8c080971d88ea86d6287f4418cd9e8f29f9066539b65830df54c2ff";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpine386 = import ./alpine.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "sha256-wJf5sDrtu+SBslgFGU6alg6bmJ+v5gt3dBabnnllJXM=";
    imageDigest = "sha256:9b9ebaba5ccb78ee301bec0b365d4d014973b05bd77a7bf59cb18f8b160a09c4";
    inherit extraCommands entrypoint shadowSetup version;
  };
}
