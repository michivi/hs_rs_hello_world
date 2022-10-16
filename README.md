# Build and call Rust code from Haskell

## Description

This is just an experiment to demonstrate that:

- A Haskell package can call Rust code
- The Cabal package can be configured to automatically build the Rust dependency

## Commands

- `nix build .` builds the Haskell program.
- `nix build .#rs_hello_world` builds the Rust library.
- `nix develop` enters the development Shell for the Haskell program.
