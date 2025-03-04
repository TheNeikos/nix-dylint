# Dylint as a nix library

This repository contains a nix library that allows easy access to the
[dylint](https://github.com/trailofbits/dylint) project in a reproducible way.


## How to use

Dylint has some [great
documentation](https://github.com/trailofbits/dylint/blob/f4cdda1d071022a2bb846b810333544d1238559b/docs/2024-10-11%20Linting%20with%20Dylint%20(EuroRust).pdf)
on how Dylint itself works.

This library then compiles and assembles the different parts you need to get it
working inside nix.

### Prerequisites

Using `nix-dylint` requires the following:

- A `nixpkgs` instance with the `rust-overlay` applied from
  [`oxalica/rust-overlay`](https://github.com/oxalica/rust-overlay/tree/master).
- A list of lints and their nightly toolchains, formatted as e.g.
  `nightly-{date}`

### Building a dylint instance

Dylint tries its best to do everything for you, but this clashes with the way
`nix`-users generally use their software. So this library generates a
`cargo-dylint` wrapper with the relevant env variables set such that it should
not build anything.

Assembling it all, it might look like this:

```nix
    dylintLib = inputs.nix-dylint.mkLib { inherit pkgs crane; };
    dylint = dylintLib.mkDylint { lints = [
        {
            toolchain = "nightly-2025-01-09";
            package = dylintLib.cargo-dylint-general;
        }
    ]; }
```


`dylint` is then a derivation that provides the `cargo-dylint` executable. One
can then use it as usual.
