with import (import ./pkgs.nix) { };
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
      unpackPhase = "cp $src ngrok";
      buildPhase = "chmod a+x ngrok";
      installPhase = ''
        install -D ngrok $out/bin/ngrok
      '';
    };
  ngrokBinArm = ngrokDrv releases.arm;
  ngrokBinAmd64 = ngrokDrv releases.amd64;
  ngrokBinArm64 = ngrokDrv releases.arm64;
  ngrokBini386 = ngrokDrv releases.i386;
  shadowSetup = with pkgs; [
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
    echo "web_addr: 0.0.0.0:4040" > .${configDir}/ngrok.yml
  '';
in {
  debianArm64 = import ./debian.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm64 = import ./alpine.nix {
    ngrokBin = ngrokBinArm64;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    inherit extraCommands entrypoint shadowSetup version;
  };
  debianAmd64 = import ./debian.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  alpineAmd64 = import ./alpine.nix {
    ngrokBin = ngrokBinAmd64;
    arch = "amd64";
    inherit pkgs extraCommands entrypoint shadowSetup version;
  };
  debianArm = import ./debian.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpineArm = import ./alpine.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm";
    pkgs = pkgsCross.armv7l-hf-multiplatform;
    inherit extraCommands entrypoint shadowSetup version;
  };
  debian386 = import ./debian.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    inherit extraCommands entrypoint shadowSetup version;
  };
  alpine386 = import ./alpine.nix {
    ngrokBin = ngrokBini386;
    arch = "i386";
    pkgs = pkgsCross.gnu32;
    inherit extraCommands entrypoint shadowSetup version;
  };
}
