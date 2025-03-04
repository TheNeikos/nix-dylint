{
  pkgs,
  craneLib,
  ...
}:

let
  callPackage = pkgs.lib.callPackageWith (pkgs // packages // { inherit craneLib; });
  packages = {
    cargo-dylint = callPackage ./cargo-dylint.nix { };
    cargo-dylint-general = callPackage ./cargo-dylint-general.nix { };

    mkCargoDylintDriver = callPackage ./mk-cargo-dylint-driver.nix { };
    mkLint = callPackage ./mk-lint.nix { };
    mkDylint = callPackage ./mk-dylint.nix { };
  };

in
packages
