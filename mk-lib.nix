{ pkgs, crane }:

import ./lib {
  inherit pkgs;
  craneLib = (crane.mkLib pkgs).overrideToolchain pkgs.rust-bin.stable.latest.default;
}
