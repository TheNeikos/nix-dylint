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

        rustTarget = pkgs.rust-bin.stable.latest.default.override { };
        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustTarget;

        lib = import ./lib {
          inherit
            inputs
            craneLib
            pkgs
            ;
        };

        lints = [
          {
            toolchain = "2025-01-09";
            package = lib.cargo-dylint-general;
          }
        ];
        dylint = lib.mkDylint { inherit lints; };
      in
      {
        packages = lib // {
          inherit craneLib;
          rust = rustTarget;
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            rustTarget
            dylint
          ];
        };
      }
    );
}
