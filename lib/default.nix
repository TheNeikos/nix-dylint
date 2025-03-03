{
  callPackage,
  ...
}:

{
  packages = {
    cargo-dylint = callPackage ./cargo-dylint.nix {};
  };
}
