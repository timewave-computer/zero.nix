{ crane, rust-overlay }:

{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      let
        contractOpts = {
          options.src = lib.mkOption {
            type = types.path;
          };
          options.contractsDir = lib.mkOption {
            type = types.str;
            default = "contracts";
            description = "directory to search for contracts in";
          };
          options.packages = lib.mkOption {
            type = types.nullOr (types.listOf types.str);
            default = null;
            defaultText = "all contracts in \${contractsDir}";
            description = "contract packages to install";
          };
          options.rustVersion = lib.mkOption {
            type = types.str;
            default = "1.81.0"; # based on cosmwasm/optimizer
            defaultText = "rust version in nixpkgs input";
          };
        };
      in
      {
        options.valence-contracts = mkOption {
          description = ''
            Valence program contracts to create packages for
          '';

          type = types.attrsOf (types.submodule contractOpts);
          default = { };
        };
        config = {
          packages = lib.mapAttrs' (version: vcontract: {
            name = "valence-contracts-${version}";
            value = pkgs.callPackage ./cosmwasm-contracts.nix {
              inherit rust-overlay crane version;
              inherit (vcontract) src packages contractsDir;
            };
          }) config.valence-contracts;
        };
      }
    );
  };
}
