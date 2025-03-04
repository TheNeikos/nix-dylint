{
  craneLib,
}:

toolchainName: toolchain:

let
  pname = "cargo-dylint-driver-${toolchainName}";
  version = "4.0.0";
  src = ../dylint_driver;
in

(craneLib.overrideToolchain toolchain).buildPackage ({
  inherit pname version src;

  strictDeps = true;
  cargoArtifacts = null;

  RUSTUP_TOOLCHAIN = toolchainName;

  doNotRemoveReferencesToRustToolchain = true;
})
