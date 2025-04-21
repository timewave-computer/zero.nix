{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;
in
{
  _file = ./default.nix;
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, system, ... }:
      let
        cfg = config.upload-contracts;

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
          inherit (cfg.default-inputs) cosmos-nix;
          inherit pkgs;
        };
      in
      {
        options.upload-contracts.networkDefaults = lib.mkOption {
          type = types.deferredModule;
          default = {};
          description = ''
            Default settings to merge into all networks.
            Options are the same as the ones for each network.
            Since this is a module it can dynamically reference network specific names and configuration as seen in the example.
          '';
          example = lib.literalExpression ''
            { name, ... }: {
              data-dir = "./''${name}/contracts-data";
            }
          '';
        };
        options.upload-contracts.networks = lib.mkOption {
          type = types.attrsOf (types.submodule {
              imports = [
                networkOpts
                config.upload-contracts.networkDefaults
              ];
            });
          default = {};
          description = ''
            Networks to upload contracts to.
          '';
        };
        options.upload-contracts.default-inputs = {
          zero-nix = lib.mkOption {
            type = types.path;
            internal = true;
          };
          cosmos-nix = lib.mkOption {
            type = types.path;
            internal = true;
            defaultText = "cosmos-nix input in zero.nix";
            description = ''
              Cosmos.nix input to use when setting default cosmos node packages.
            '';
          };
        };
        config = lib.mkMerge [
          {
            apps = lib.concatMapAttrs (network: networkCfg:
              lib.mapAttrs' (chain: chainCfg: {
                name = "${network}-${chain}-upload-contracts";
                value.program = pkgs.writeShellApplication {
                  name = "${network}-${chain}-upload-contracts";
                  runtimeInputs = [ cfg.default-inputs.zero-nix.packages.${system}.upload-contract ];
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
                  runtimeInputs = [ cfg.default-inputs.zero-nix.packages.${system}.upload-contract ];
                  text = ''
                    mkdir -p ${networkCfg.data-dir}
                    ${lib.concatStringsSep "\n" (lib.mapAttrsToList uploadAllChainContracts networkCfg.chains)}
                    ${lib.getExe print-contracts-toml} ${networkCfg.data-dir}/*.yaml > ${networkCfg.data-dir}/contracts.toml
                  '';
                };
              }
            ) config.upload-contracts.networks;
          }
          (lib.mkIf (config.upload-contracts.networks != {}) {
            apps.print-contracts-toml.program = pkgs.writeShellApplication {
              name = "print-contracts-toml";
              text = ''
                ${lib.getExe print-contracts-toml} "$@"
              '';
            };
          })
        ];
      }
    );
  };
}
