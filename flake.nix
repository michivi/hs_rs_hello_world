{
  description = "Example of a Rust library built and used by a Haskell package";
  inputs.haskellNix.url = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  outputs = { self, nixpkgs, flake-utils, haskellNix }:
    let
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        overlays = [
          haskellNix.overlay
          (final: prev: {
            rs_hello_world = final.rustPlatform.buildRustPackage {
              name = "rs_hello_world";
              src = ./rust;

              cargoLock = {
                lockFile = ./rust/Cargo.lock;
              };
            };
          })
          (final: prev: {
            hs_hello_world =
              final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc8107";
                modules = [{
                  packages.hello.flags.external_lib = true;
                }];
                shell.tools = {
                  cabal = { };
                };
                shell.buildInputs = with pkgs; [
                  nixpkgs-fmt
                  # Allows Cabal to build the Rust library itself when in the Devshell.
                  cargo
                ];
              };
          })
        ];
        pkgs = import nixpkgs { inherit system overlays; inherit (haskellNix) config; };
        flake = pkgs.hs_hello_world.flake { };
      in
      flake // rec {
        packages = {
          inherit (pkgs) rs_hello_world;
          hs_hello_world = flake.packages."hello:exe:hello";
        };

        # Built by `nix build .`
        defaultPackage = packages.hs_hello_world;
      });

  # --- Flake Local Nix Configuration ----------------------------
  nixConfig = {
    # This sets the flake to use the IOG nix cache.
    # Nix should ask for permission before using it,
    # but remove it here if you do not want it to.
    extra-substituters = [ "https://cache.iog.io" ];
    extra-trusted-public-keys = [ "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" ];
    allow-import-from-derivation = "true";
  };
}
