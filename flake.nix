{
  description = "Nix library to use cargo-dylint";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    crane.url = "github:ipetkov/crane";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
    inputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [
            inputs.rust-overlay.overlays.default
          ];
        };

        rustTarget = pkgs.rust-bin.nightly."2025-01-09".default.override {
          extensions = [
            "rustc-dev"
          ];
        };
        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustTarget;

        lib = import ./lib {
          inherit
            inputs
            craneLib
            pkgs
            ;
        };
        drivers = pkgs.runCommandLocal "dylint-drivers" { } ''
          mkdir -p $out/nightly-2025-01-09
          ln -s ${lib.cargo-dylint-driver}/bin/dylint_driver-nix $out/nightly-2025-01-09/dylint-driver
        '';
      in
      {
        packages = lib // {
          inherit craneLib drivers;
          rust = rustTarget;
        };

        devShells.default = pkgs.mkShell {
          RUSTUP_TOOLCHAIN = "nightly-2025-01-09";
          DYLINT_LIBRARY_PATH = "${lib.cargo-dylint-general}/lib/";
          DYLINT_DRIVER_PATH = drivers;
          nativeBuildInputs = [
            rustTarget
            lib.cargo-dylint
          ];
        };
      }
    );
}
