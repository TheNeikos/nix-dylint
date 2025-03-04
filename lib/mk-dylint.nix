{
  pkgs,

  cargo-dylint,

  mkCargoDylintDriver,
}:

{ lints }:

let
  inherit (pkgs) lib;
  driver_names = lib.groupBy (v: v.toolchain) lints;
  driverMap = builtins.mapAttrs (
    name: _:
    mkCargoDylintDriver "${name}" (
      pkgs.rust-bin.nightly."${lib.removePrefix "nightly-" name}".default.override {
        extensions = [
          "rustc-dev"
        ];
      }
    )
  ) driver_names;
  drivers = pkgs.runCommandLocal "dylint-drivers" { } ''
    mkdir -p $out

    ${lib.strings.concatMapAttrsStringSep "\n" (name: driver: ''
      mkdir -p $out/${name}
      ln -s ${driver}/bin/dylint_driver-nix $out/${name}/dylint-driver
    '') driverMap}
  '';
in
pkgs.runCommandLocal "cargo-dylint-wrapped"
  {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    meta.mainProgram = "cargo-dylint";
  }
  ''
    makeWrapper ${cargo-dylint}/bin/cargo-dylint $out/bin/cargo-dylint \
      --set-default DYLINT_LIBRARY_PATH "${lib.strings.makeLibraryPath (builtins.map (v: v.package) lints)}" \
      --set DYLINT_DRIVER_PATH ${drivers};
  ''
