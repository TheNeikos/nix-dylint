{
  pkgs,
  craneLib,

  pkg-config,
  openssl,
  util-linux,

  cargo-dylint,
}:

let
  pname = "cargo-dylint-general";
  version = "4.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "trailofbits";
    repo = "dylint";
    tag = "v${version}";
    sha256 = "sha256-Z8uuewp7Buoadayc0oTafmfvwNT36KukWKiHxL/mQfI=";
  };

  commonArgs = {
    inherit pname version;

    src = src;

    patches = [ ./cargo-dylint-general-ignore-home.patch ];

    strictDeps = true;

    buildInputs = [ openssl ];
    nativeBuildInputs = [
      pkg-config
      cargo-dylint
    ];

    cargoVendorDir = craneLib.vendorCargoDeps { cargoLock = ./cargo-dylint-general-Cargo.lock; };

    preBuild = ''
      cd examples/general
      mkdir -p .cargo
    '';


    CARGO_TARGET_X86_64_UNKNOWN_LINUX_GNU_LINKER = "dylint-link";

    cargoExtraArgs = "-p crate_wide_allow";

    RUSTUP_TOOLCHAIN = "nightly-2025-01-09";
  };
in

craneLib.buildPackage (
  commonArgs
  // {
    cargoArtifacts = null;

    doCheck = false;

    postFixup = ''
      ${util-linux}/bin/rename .so @$RUSTUP_TOOLCHAIN.so $out/lib/*.so
    '';

    doNotRemoveReferencesToRustToolchain = true;
  }
)
