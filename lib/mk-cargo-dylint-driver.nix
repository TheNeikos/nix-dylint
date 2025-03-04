{
  pkgs,
  craneLib,
}:

toolchainName:

let
  pname = "cargo-dylint-driver-${toolchainName}";
  version = "4.0.0";
  src = ../dylint_driver;
  toolchain =
    (pkgs.rust-bin.fromRustupToolchainFile (
      pkgs.writeText "${toolchainName}-toolchain.toml" toolchainName
    )).override
      {
        extensions = [
          "rustc-dev"
        ];
      };

in

(craneLib.overrideToolchain toolchain).buildPackage ({
  inherit pname version src;

  strictDeps = true;
  cargoArtifacts = null;

  RUSTUP_TOOLCHAIN = toolchainName;

  doNotRemoveReferencesToRustToolchain = true;
})
