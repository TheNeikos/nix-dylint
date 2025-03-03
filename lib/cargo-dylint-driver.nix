{
  craneLib,
}:

let
  pname = "cargo-dylint-driver";
  version = "4.0.0";

  src = ../dylint_driver;

  commonArgs = {
    inherit pname version src;

    strictDeps = true;

    RUSTUP_TOOLCHAIN = "nightly-2025-01-09";
  };
in

craneLib.buildPackage (
  commonArgs
  // {
    cargoArtifacts = craneLib.buildDepsOnly commonArgs;

    doNotRemoveReferencesToRustToolchain = true;
  }
)
