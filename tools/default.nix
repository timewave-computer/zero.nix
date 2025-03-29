{ lib, flake-parts-lib, inputs, ... }:
let
  inherit (flake-parts-lib) mkTransposedPerSystemModule;
  inherit (lib) types mkOption;
in
{
  imports = [
    (mkTransposedPerSystemModule {
      name = "tools";
      option = mkOption {
        type = with types; lazyAttrsOf (functionTo package);
        default = { };
        description = ''
          An attribute set of functions that build packages
        '';
      };
      file = ./tools.nix;
    })
  ];

  perSystem = { pkgs, lib, ... }: {
    tools.buildValenceContracts = import ./build-valence-contracts {
      inherit pkgs;
      inherit (inputs) crane rust-overlay;
    };
  };
}
