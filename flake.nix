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
          overlays = let
            selfOverlay = _: _: inputs.self.packages."${system}" or {};
          in [
            selfOverlay
            inputs.rust-overlay.overlays.default
          ];
        };

        rustTarget = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        craneLib = (inputs.crane.mkLib pkgs).overrideToolchain rustTarget;

        callPackage = pkgs.lib.callPackageWith (
          pkgs
          // {
            inherit
              inputs
              craneLib
              ;
          }
        );

        lib = import ./lib {
          inherit
            inputs
            callPackage
            ;
        };
      in
      {
        inherit lib;

        packages = lib.packages;

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            pkgs.rust-bin.nightly.latest.default
          ];
        };
      }
    );
}
