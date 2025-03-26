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
          _module.args = {
            inherit pkgs;
          };
        };

        print-contracts-toml = pkgs.writeShellApplication {
          name = "print-contracts-toml";
          runtimeInputs = with pkgs; [ yq coreutils ];
          text = builtins.readFile ./print-contracts-toml.bash;
        };

        uploadContract = label: contract: with contract; ''
          export CONTRACT_PATH="${path}"
          export CONTRACT_LABEL="${label}"
          export INSTANTIATE="${instantiate}"
          export INITIAL_STATE="${initial-state}"
          export SOURCE="${source}"
          upload-contract "$@"
        '';
        uploadAllChainContracts = chain: chainCfg: with chainCfg; ''
          export COMMAND="${command}"
          export CHAIN_ID="${chain-id}"
          export ADMIN_ADDRESS="${admin-address}"
          export NODE_ADDRESS="${node-address}"
          export MAX_FEES="${max-fees}"
          export DENOM="${denom}"
          export GAS_MULTIPLIER="${gas-multiplier}"
          export FROM_ADDRESS="${from-address}"
          export DATA_FILE="${data-file}"
          export KEYRING_BACKEND="${keyring-backend}"
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList uploadContract contracts)}
        '';
      in
      {
        options.upload-contracts.networks = lib.mkOption {
          type = types.attrsOf (types.submodule ({name, ...}@args: {
            options.data-dir = lib.mkOption {
              description = ''
                where to store data about contracts
              '';
              default = "${args.name}-contracts";
              type = types.str;
            };
            options.chains = lib.mkOption {
              description = ''
                Chains to upload contracts to
              '';

              type = types.attrsOf (types.submodule {
                _module.args = { inherit (args.config) data-dir; };
                imports = [
                  chainOpts
                ] ++ args.options.chainDefaults.definitions;
              });

              default = { };
            };
            options.chainDefaults = lib.mkOption {
              type = types.submodule {
                _module.args.name = lib.mkForce "<name>";
                _module.args = { inherit (args) data-dir; };
                imports = [ chainOpts ];
              };
              default = {};
              description = ''
                Default settings for all chains
              '';
            };
          }));
        };

        config = lib.mkMerge [
          {
            apps = lib.concatMapAttrs (network: networkCfg:
              lib.mapAttrs' (chain: chainCfg: {
                name = "${network}-${chain}-upload-contracts";
                value.program = pkgs.writeShellApplication {
                  name = "${network}-${chain}-upload-contracts";
                  runtimeInputs = [ zero-nix.packages.${pkgs.system}.upload-contract ];
                  text = ''
                    mkdir -p ${networkCfg.data-dir}
                    ${uploadAllChainContracts chain chainCfg}
                    ${lib.getExe print-contracts-toml} ${networkCfg.data-dir}/${chain}.yaml
                  '';
                };
              }) networkCfg.chains
              // {
                "${network}-upload-contracts".program = pkgs.writeShellApplication {
                  name = "${network}-upload-contracts";
                  runtimeInputs = [ zero-nix.packages.${pkgs.system}.upload-contract ];
                  text = ''
                    mkdir -p ${networkCfg.data-dir}
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList uploadAllChainContracts networkCfg.chains)}
                    ${lib.getExe print-contracts-toml} ${networkCfg.data-dir}/*.yaml > ${networkCfg.data-dir}/contracts.toml
                  '';
                };
              }
            ) config.upload-contracts.networks;
          }
          {
            apps.print-contracts-toml.program = pkgs.writeShellApplication {
              name = "print-contracts-toml";
              text = ''
                ${lib.getExe print-contracts-toml} "$@"
              '';
            };
          }
        ];
      }
    );
  };
}
