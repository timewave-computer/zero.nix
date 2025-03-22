{ zero-nix }:

{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, options, pkgs, ... }:
      let
        chainOpts = {
          imports = [ ./chain-opts.nix ];
          _module.args = { inherit pkgs; };
        };

        uploadContract = label: contract: with contract; ''
          export CONTRACT_PATH=${path}
          export CONTRACT_LABEL=${label}
          export INSTANTIATE=${instantiate}
          export INITIAL_STATE=${initial-state}
          upload-contract "$@"
        '';
      in
      {
        options.upload-contracts.chains = lib.mkOption {
          description = ''
            Chains to upload contracts to
          '';

          type = types.lazyAttrsOf (types.submodule {
            imports = [
              chainOpts
            ] ++ options.upload-contracts.chainDefaults.definitions;
          });

          default = { };
        };
        options.upload-contracts.chainDefaults = lib.mkOption {
          type = types.submodule {
            _module.args.name = lib.mkForce "<name>";
            imports = [ chainOpts ];
          };
          default = {};
          description = ''
            Default settings for all chains
          '';
        };

        config = {
          apps = lib.mapAttrs' (name: chain: {
            name = "${name}-upload-contracts";
            value.program = pkgs.writeShellApplication {
              name = "${name}-upload-contracts";
              runtimeInputs = [ zero-nix.packages.${pkgs.system}.upload-contract ];
              text = with chain; ''
                export COMMAND=${command}
                export CHAIN_ID=${chain-id}
                export ADMIN_ADDRESS=${admin-address}
                export NODE_ADDRESS=${node-address}
                export MAX_FEES=${max-fees}
                export DENOM=${denom}
                export GAS_MULTIPLIER=${gas-multiplier}
                export FROM_ADDRESS=${from-address}
                export CONTRACT_LABEL=${label}
                export DATA_DIR=${data-dir}
                export KEYRING_BACKEND=${keyring-backend}
                ${lib.concatStringsSep "\n" (lib.mapAttrsToList uploadContract contracts)}
              '';
            };
          }) config.upload-contracts.chains;
        };
      }
    );
  };
}
