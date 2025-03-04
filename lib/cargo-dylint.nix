{
  pkgs,
  craneLib,

  pkg-config,
  openssl,
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

  commonArgs = {
    inherit pname version src;

    buildInputs = [
      openssl
    ];

    nativeBuildInputs = [
      pkg-config
    ];

    RUSTUP_TOOLCHAIN = "nightly-2025-01-09";

    doCheck = false;
  };
  cargoArtifacts = craneLib.buildDepsOnly commonArgs;
in

craneLib.buildPackage (
  commonArgs
  // {
    inherit cargoArtifacts;

    doNotRemoveReferencesToRustToolchain = true;
  }
)
