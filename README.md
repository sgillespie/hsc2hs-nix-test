# hsc2hs nix flake

A nix flake intended to test cross-compiling hsc2hs in text-icu

## Usage

To test a native build:

    nix build -L .#

To test a cross build:

    nix build -L .#aarch64-unknown-linux-musl:text-icu:lib:text-icu

Notice the values of `--hsc2hs-option`s that are passed to cabal configure
