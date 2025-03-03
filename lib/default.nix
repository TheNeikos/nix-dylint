{
  pkgs,
  inputs,
  craneLib,
  ...
}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages // { inherit inputs craneLib; });
  packages = {
    cargo-dylint = callPackage ./cargo-dylint.nix { };
    cargo-dylint-driver = callPackage ./cargo-dylint-driver.nix { };
    cargo-dylint-general = callPackage ./cargo-dylint-general.nix { };
  };

in
packages
