{ zero-nix, cosmos-nix }:

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

        networkOpts = import ./network-opts.nix {
          inherit cosmos-nix pkgs;
        };
      in
      {
        options.upload-contracts.networkDefaults = lib.mkOption {
          type = types.submodule {
            _module.args.name = lib.mkForce "<name>";
            imports = [ networkOpts ];
          };
          default = {};
        };
        options.upload-contracts.networks = lib.mkOption {
          type = types.attrsOf (types.submodule {
              imports = [
                networkOpts
              ] ++ options.upload-contracts.networkDefaults.definitions;
            });
          default = {};
        };
        config = lib.mkMerge [
          {
            apps = lib.concatMapAttrs (network: networkCfg:
              lib.mapAttrs' (chain: chainCfg: {
                name = "${network}-${chain}-upload-contracts";
                value.program = pkgs.writeShellApplication {
                  name = "${network}-${chain}-upload-contracts";
                  runtimeInputs = [ zero-nix.packages.upload-contract ];
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
                  runtimeInputs = [ zero-nix.packages.upload-contract ];
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
