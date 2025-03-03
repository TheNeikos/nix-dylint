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
  };

in
packages
