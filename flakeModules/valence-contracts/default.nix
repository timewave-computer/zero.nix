{ crane }:

{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) mkOption types;

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
  };
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
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
              inherit crane version;
              inherit (vcontract) src packages contractsDir;
            };
          }) config.valence-contracts;
        };
      }
    );
  };
}
