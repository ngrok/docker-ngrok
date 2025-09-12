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
    imageSha256 = "13h5sh8fnxyaw7n69h7865ybda6lr7vhagf5fgxwjm8yr1pxf3li";
    imageDigest =
      "sha256:53b74ddfc6225e3c8cc84d7985d0f34666e4e8b0b6892a9b2ad1f7516bc21b54";
    inherit extraCommands entrypoint shadowSetup version;
  };
  debianAmd64 = import ./debian.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageSha256 = "0nar4n6kwhqqlkafvpjlxxkw3axhvlbfs6vl4z6sxzv3q9zl0vsf";
    imageDigest =
      "sha256:5625c115ad881f19967a9b66416f8d40710bb307ad607d037f8ad8289260f75f";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  alpineAmd64 = import ./alpine.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    imageDigest =
      "sha256:1775bebec23e1f3ce486989bfc9ff3c4e951690df84aa9f926497d82f2ffca9d";
    imageSha256 = "1jjqqp6vkmmy1i37dk0z3slsdbjahy9shsm7vhhrk07kgx8ia7xs";
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
