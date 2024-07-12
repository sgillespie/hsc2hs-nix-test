{
  inputs = {
    haskellNix.url = "github:input-output-hk/haskell.nix";
    nixpkgs.follows = "haskellNix/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    hsc2hs = {
      url = "github:sgillespie/hsc2hs";
      flake = false;
    };

    text-icu = {
      url = "github:haskell/text-icu";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, haskellNix, ... }@attrs:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
    let
      overlays = [
        haskellNix.overlay

        (final: prev: rec {
          hsc2hsProject = final.haskell-nix.cabalProject' {
            src = attrs.hsc2hs;
            compiler-nix-name = "ghc96";
          };

          hsc2hs = hsc2hsProject.hsPkgs.hsc2hs.components.exes.hsc2hs;
        })

        (final: prev: {
          textIcuProject = final.haskell-nix.project' {
              src = attrs.text-icu;
              compiler-nix-name = "ghc96";

              modules = [
                ({ pkgs, ... }: {
                  packages.text-icu.configureFlags =
                    let
                      hsc2hs = prev.pkgsBuildBuild.hsc2hs;
                    in
                      [ "--with-hsc2hs=${hsc2hs}/bin/hsc2hs" ];
                })
              ];

          };
        })
      ];

      pkgs = import nixpkgs {
        inherit system overlays;
        inherit (haskellNix) config;
      };

      flake = pkgs.textIcuProject.flake {
        crossPlatforms = p: [
          p.aarch64-multiplatform-musl
        ];
      };
    in flake // {
      packages =
        flake.packages // {
          default = flake.packages."text-icu:lib:text-icu";
        };
    });
}
