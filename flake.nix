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
    (
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

          dylintLib = import ./mk-lib.nix {
            inherit pkgs;
            inherit (inputs) crane;
          };

          lints = [
            {
              toolchain = "nightly-2025-01-09";
              package = dylintLib.cargo-dylint-general;
            }
          ];
          dylint = dylintLib.mkDylint { inherit lints; };
        in
        {

          devShells.default = pkgs.mkShell {
            nativeBuildInputs = [
              rustTarget
              dylint
            ];
          };
        }
      )
      // {

        mkLib = import ./mk-lib.nix;
      }
    );
}
