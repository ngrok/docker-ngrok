with import (import ./pkgs.nix) { };
with stdenv;
let
  configDir = "/var/lib/ngrok";
  releases = builtins.fromJSON (builtins.readFile ./releases.json);
  ngrokDrv = { version, sha256, url }:
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
  ngrokBinAmd = ngrokDrv releases.amd64;
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
  debianArm = import ./debian.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    inherit extraCommands entrypoint shadowSetup;
  };
  alpineArm = import ./alpine.nix {
    ngrokBin = ngrokBinArm;
    arch = "arm64";
    pkgs = pkgsCross.aarch64-multiplatform;
    inherit extraCommands entrypoint shadowSetup;
  };
  debian = import ./debian.nix {
    ngrokBin = ngrokBinAmd;
    arch = "amd64";
    inherit pkgs extraCommands entrypoint shadowSetup;
  };
  alpine = import ./alpine.nix {
    ngrokBin = ngrokBinAmd;
    arch = "amd64";
    inherit pkgs extraCommands entrypoint shadowSetup;
  };
}
