{
  pkgs,
  craneLib,

  cargo-dylint,

  mkCargoDylintDriver,
}:

{ lints }:

let
  inherit (pkgs) lib;
  driver_names = lib.groupBy (v: v.toolchain) lints;
  toolchains = builtins.mapAttrs (
    name: _:

    (pkgs.rust-bin.fromRustupToolchainFile (pkgs.writeText "${name}-toolchain.toml" name)).override {
      extensions = [
        "rustc-dev"
      ];
    }
  ) driver_names;
  driverMap = builtins.mapAttrs (
    name: _:
    lib.throwIf ((builtins.match "^[[:digit:]].*$" name) != null)
      "Rust toolchains generally do not start with numbers. Make sure you include the channel, as in `nightly-YYYY-MM-DD`. Given '${name}'"
      mkCargoDylintDriver
      "${name}"
      toolchains.${name}
  ) driver_names;
  drivers = pkgs.runCommandLocal "dylint-drivers" { } ''
    mkdir -p $out

    ${lib.strings.concatMapAttrsStringSep "\n" (name: driver: ''
      mkdir -p $out/${name}
      ln -s ${driver}/bin/dylint_driver-nix $out/${name}/dylint-driver
    '') driverMap}
  '';
  cargo-wrapper = pkgs.writeShellScriptBin "cargo" ''
    case "$RUSTUP_TOOLCHAIN" in
    ${lib.strings.concatMapAttrsStringSep "\n" (name: _: ''
      ${name})
        exec ${toolchains.${name}}/bin/cargo "$@"
      ;;
    '') driverMap}
      *)
        exec ${craneLib.cargo}/bin/cargo "$@"
      ;;
    esac
  '';
  rustc-wrapper = pkgs.writeShellScriptBin "rustc" ''
    case "$RUSTUP_TOOLCHAIN" in
    ${lib.strings.concatMapAttrsStringSep "\n" (name: _: ''
      ${name})
        exec ${toolchains.${name}}/bin/rustc "$@"
      ;;
    '') driverMap}
      *)
        exec ${craneLib.rustc}/bin/rustc "$@"
      ;;
    esac
  '';
in
pkgs.runCommandLocal "cargo-dylint-wrapped"
  {
    nativeBuildInputs = [ pkgs.makeWrapper ];
    meta.mainProgram = "cargo-dylint";
    passthru = {
      inherit lints;
      DYLINT_LIBRARY_PATH = lib.strings.makeLibraryPath (builtins.map (v: v.package) lints);
      DYLINT_DRIVER_PATH = drivers;
    };
  }
  ''
    makeWrapper ${cargo-dylint}/bin/cargo-dylint $out/bin/cargo-dylint \
      --set-default DYLINT_LIBRARY_PATH "${
        lib.strings.makeLibraryPath (builtins.map (v: v.package) lints)
      }" \
      --set DYLINT_DRIVER_PATH ${drivers} \
      --prefix PATH : ${
        lib.makeBinPath [
          cargo-wrapper
          rustc-wrapper
        ]
      }

    ln -s ${cargo-dylint}/bin/dylint-link $out/bin/dylint-link
  ''
