{
  pkgs,
  craneLib,

  pkg-config,
  openssl,

  cargo-dylint-driver,
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

    patches = [ ./cargo-dylint-patch-rustup.patch ];

    postPatch = ''
      substituteInPlace dylint/build.rs \
        --replace-fail @DRIVER_DIR@ ${src}/driver

      substituteInPlace internal/src/cargo.rs \
        --replace-fail @STABLE_CARGO@ ${craneLib.cargo}/bin/cargo

      substituteInPlace internal/src/rustup.rs \
        --replace-fail @RUST_TOOLCHAIN@ $RUSTUP_TOOLCHAIN \
        --replace-fail @RUST_TOOLCHAIN_PATH@ ${craneLib.rustc}
    '';

    doNotRemoveReferencesToRustToolchain = true;
  }
)
