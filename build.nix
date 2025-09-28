{ pkgs, stdenv, pkgsCross, fetchurl, unzip, writeTextDir }:
with stdenv;
let
  configDir = "/var/lib/ngrok";
  releases = builtins.fromJSON (builtins.readFile ./releases.json);
  version = releases.version;
  ngrokDrv = { sha256, url }:
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
    imageSha256 = "1vdhk5hrjmgicrnlzr7dpkv23whncx2ypk5s320l02h6ck5kbvxl";
    imageDigest =
      "sha256:eb9b613b4f63193f4476e62af4cb5bff5e3ba0683c4c7f317b2a2c7e3ec22ee6";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm64 = import ./alpine.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    imageSha256 = "1abijbbhnxja3pli3v77kgdafpyhw4jaw3nkna0l6zyfklp2vlsz";
    imageDigest = "sha256:4562b419adf48c5f3c763995d6014c123b3ce1d2e0ef2613b189779caa787192";
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
    imageDigest = "sha256:eafc1edb577d2e9b458664a15f23ea1c370214193226069eb22921169fc7e43f";
    imageSha256 = "0rq7l1r7d6iidcjycc2vlgnhz64rckiabw3i51fgdbcbw0l1wd83";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  debianArm = import ./debian.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "1aiqszdbcbx93g64sd5m7c39wr86m8l38s6psyaw6d0jgpmd6r67";
    imageDigest =
      "sha256:32c2874ad59bf7908d2a9f7b25409b17cd2927e852d46ed91acfcca4fb64590f";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm = import ./alpine.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    imageSha256 = "1idf4x6dk290wm731yjpf2swyrlajbdd9bg3z7vvsrrzz2gsdgjn";
    imageDigest =
      "sha256:8d99168167baa6a6a0d7851b9684625df9c1455116a9601835c2127df2aaa2f5";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debian386 = import ./debian.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "0h1x1qjawkr857drkq9llrrjpmkrbkad0xjyvr4xqqnvp3jv76nf";
    imageDigest =
      "sha256:8aa52e36d688dfaf6a949884cecc0aa5bd0bc92a626b11c2feeb8a23fbcf3190";
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpine386 = import ./alpine.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    imageSha256 = "07lapaqi63rz58fxhp13h673aj3mpsxkl0mhb4hxprkpg58hfgh0";
    imageDigest =
      "sha256:52a197664c8ed0b4be6d3b8372f1d21f3204822ba432583644c9ce07f7d6448f";
    inherit extraCommands entrypoint shadowSetup version;
  };
}
