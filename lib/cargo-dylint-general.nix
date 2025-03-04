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

  crane = craneLib.overrideToolchain (
    pkgs.rust-bin.nightly."2025-01-09".default.override { extensions = [ "rustc-dev" ]; }
  );

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

    cargoVendorDir = crane.vendorCargoDeps { cargoLock = ./cargo-dylint-general-Cargo.lock; };

    preBuild = ''
      cd examples/general
      mkdir -p .cargo
    '';

    cargoExtraArgs = "-p general";

    RUSTUP_TOOLCHAIN = "nightly-2025-01-09";
  };
in

crane.buildPackage (
  commonArgs
  // {
    cargoArtifacts = null;

    doCheck = false;

    postFixup = ''
      mv $out/lib/libgeneral{.so,@$RUSTUP_TOOLCHAIN.so}
    '';

    doNotRemoveReferencesToRustToolchain = true;
  }
)
