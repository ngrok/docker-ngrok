let
  # Follow from http://hydra.nixos.org/job/nixpkgs/trunk/unstable through a
  # passing hydra build and nab the commit from that.
  # This ensures the upstream nix cache has all artifacts for this commit.
  commit = "a916ffbb2752be32b1d44cf40bed4dbc1974da62";
  url = "https://github.com/NixOS/nixpkgs/archive/${commit}.tar.gz";
in builtins.fetchTarball {
  inherit url;

  sha256 = "1xn3lqiyp1x1qq9kb7prqzbdy2brabspsyh7j8x6srj4600gif5l";
}
