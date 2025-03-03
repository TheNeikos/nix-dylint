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
in

craneLib.buildPackage {
  inherit
    pname
    version
    src
    ;

  buildInputs = [
    openssl
  ];

  nativeBuildInputs = [
    pkg-config
  ];

  RUSTUP_TOOLCHAIN = craneLib.rustc.version;

  doCheck = false;
}
