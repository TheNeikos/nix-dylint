{
  pkgs,
  craneLib,
  ...
}:

let
  pname = "cargo-dylint";
  version = "4.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "trailofbits";
    repo = "dylint";
    tag = "v${version}";
    sha256 = "sha256-Z8uuewp7Buoadayc0oTafmfvwNT36KukWKiHxL/mQfI=";
  };

  cargoArtifacts = craneLib.buildDepsOnly {
    inherit pname version src;
  };
in craneLib.buildPackage {
  inherit
    cargoArtifacts
    pname
    version
    src
    ;
}
