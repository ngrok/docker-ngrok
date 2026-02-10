{
  perSystem =
    { pkgs, ... }:
    let
      configDir = "/var/lib/ngrok";
      releases = builtins.fromJSON (builtins.readFile ./releases.json);
      version = releases.version;
      ngrokDrv =
        { sha256, url }:
        pkgs.stdenv.mkDerivation {
          name = "ngrok-${version}";
          version = version;
          src = pkgs.fetchurl { inherit sha256 url; };
          sourceRoot = ".";
          unpackPhase = "${pkgs.unzip}/bin/unzip $src ngrok";
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
        (pkgs.writeTextDir "etc/shadow" ''
          root:!x:::::::
          ngrok:!:::::::
        '')
        (pkgs.writeTextDir "etc/passwd" ''
          root:x:0:0::/root:/bin/bash
          ngrok:x:1000:100::/home/ngrok:
        '')
        (pkgs.writeTextDir "etc/group" ''
          root:x:0:
          ngrok:x:100:
        '')
        (pkgs.writeTextDir "etc/gshadow" ''
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
    {
      packages.debianArm64 = import ./debian.nix {
        ngrokBin = ngrokBinArm64;
        arch = "arm64";
        pkgs = pkgs.pkgsCross.aarch64-multiplatform;
        imageSha256 = "0q569s2dbgqzckvdpmf6qppqxqdis6l2g7qz14vhxq29hqzbw1hd";
        imageDigest = "sha256:53692cdc49e2b0abdd9adf36466b366aaebdbbdbb2e6a7f432e2b4fb7327fd93";
        inherit extraCommands entrypoint shadowSetup version;
      };
      packages.alpineArm64 = import ./alpine.nix {
        ngrokBin = ngrokBinArm64;
        arch = "arm64";
        pkgs = pkgs.pkgsCross.aarch64-multiplatform;
        imageSha256 = "1abijbbhnxja3pli3v77kgdafpyhw4jaw3nkna0l6zyfklp2vlsz";
        imageDigest = "sha256:4562b419adf48c5f3c763995d6014c123b3ce1d2e0ef2613b189779caa787192";
        inherit extraCommands entrypoint shadowSetup version;
      };
      packages.debianAmd64 = import ./debian.nix {
        ngrokBin = ngrokBinAmd64;
        arch = "amd64";
        imageSha256 = "1jf3hq38l7ca087whvj1pg82dyqm62fz83mrkq6gfnfr8am0wx2z";
        imageDigest = "sha256:3f03ff2fca74e47cee05599e36e1f1258d386895a3394b3683df333f404f4e8a";
        inherit pkgs extraCommands entrypoint shadowSetup version;
      };
      packages.alpineAmd64 = import ./alpine.nix {
        ngrokBin = ngrokBinAmd64;
        arch = "amd64";
        imageDigest = "sha256:eafc1edb577d2e9b458664a15f23ea1c370214193226069eb22921169fc7e43f";
        imageSha256 = "0rq7l1r7d6iidcjycc2vlgnhz64rckiabw3i51fgdbcbw0l1wd83";
        inherit pkgs extraCommands entrypoint shadowSetup version;
      };
      packages.debianArm = import ./debian.nix {
        ngrokBin = ngrokBinArm;
        arch = "arm";
        pkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
        imageSha256 = "10xgf8nb482qpxv16k9aaa06y5ahh99w5bcxywfv7wnp2as1di0p";
        imageDigest = "sha256:30c1b3317f599c1843157fb240ddbf4eafbccc70f6dbd7ba29dc1f7452309dd1";
        inherit extraCommands entrypoint shadowSetup version;
      };
      packages.alpineArm = import ./alpine.nix {
        ngrokBin = ngrokBinArm;
        arch = "arm";
        pkgs = pkgs.pkgsCross.armv7l-hf-multiplatform;
        imageSha256 = "085m2dvynld6lxysiqafgaw5nd65ddwia5mpsvvckk7agi3ahhxh";
        imageDigest = "sha256:9a00b501930d225081164db0456189ebc25b9c7524989c38f4d77c0a96a9ca9a";
        inherit extraCommands entrypoint shadowSetup version;
      };
      packages.debian386 = import ./debian.nix {
        ngrokBin = ngrokBini386;
        arch = "i386";
        pkgs = pkgs.pkgsCross.gnu32;
        imageSha256 = "0rgzkk0f73j7czcxddxzzzj163k7ki034hcjw4dgfskq14k2nrfk";
        imageDigest = "sha256:82c5ce38c8c080971d88ea86d6287f4418cd9e8f29f9066539b65830df54c2ff";
        inherit extraCommands entrypoint shadowSetup version;
      };
      packages.alpine386 = import ./alpine.nix {
        ngrokBin = ngrokBini386;
        arch = "i386";
        pkgs = pkgs.pkgsCross.gnu32;
        imageSha256 = "1p9sxs65839az9iczx1m3jiz0dbq0zkns6nnf5ahrxj5jhih32rk";
        imageDigest = "sha256:0a88b42ba69d6b900848f9cb9151587bb82827d0aecfa222e51981fad97b5b9a";
        inherit extraCommands entrypoint shadowSetup version;
      };
    };
}
