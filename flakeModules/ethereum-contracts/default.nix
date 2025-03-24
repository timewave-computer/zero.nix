{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;
in
{
  options = {
    perSystem = mkPerSystemOption (
      { config, pkgs, ... }:
      let
        ethereumOpts = {
          options = {
            rpcUrl = lib.mkOption {
              type = types.str;
              description = "RPC URL for the Ethereum node";
              example = "http://localhost:8545";
            };
            
            privateKey = lib.mkOption {
              type = types.str;
              description = "Private key for transaction signing";
            };
            
            gasPrice = lib.mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Gas price for transactions (null for auto)";
            };
            
            gasLimit = lib.mkOption {
              type = types.nullOr types.int;
              default = null;
              description = "Gas limit for transactions (null for auto)";
            };

            contracts = lib.mkOption {
              type = types.attrsOf (types.submodule {
                options = {
                  path = lib.mkOption {
                    type = types.path;
                    description = "Path to the compiled contract JSON";
                  };
                  
                  constructorArgs = lib.mkOption {
                    type = types.listOf types.str;
                    default = [];
                    description = "Constructor arguments for contract deployment";
                  };
                  
                  verifyContract = lib.mkOption {
                    type = types.bool;
                    default = false;
                    description = "Whether to verify the contract on Etherscan";
                  };
                  
                  etherscanApiKey = lib.mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = "Etherscan API key for contract verification";
                  };
                };
              });
              default = {};
              description = "Ethereum contracts to deploy";
            };
          };
        };
        
        deployContract = name: contract: ''
          echo "Deploying contract: ${name}"
          forge create --rpc-url "${config.ethereum-contracts.rpcUrl}" \
            --private-key "${config.ethereum-contracts.privateKey}" \
            ${lib.optionalString (config.ethereum-contracts.gasPrice != null) "--gas-price ${config.ethereum-contracts.gasPrice}"} \
            ${lib.optionalString (config.ethereum-contracts.gasLimit != null) "--gas-limit ${toString config.ethereum-contracts.gasLimit}"} \
            ${contract.path} \
            ${lib.optionalString (contract.constructorArgs != []) "--constructor-args ${lib.concatStringsSep " " contract.constructorArgs}"} \
            --json > $DEPLOYMENT_DIR/${name}.json
          
          CONTRACT_ADDRESS=$(jq -r '.deployedTo' $DEPLOYMENT_DIR/${name}.json)
          echo "${name} deployed to: $CONTRACT_ADDRESS"
          
          ${lib.optionalString contract.verifyContract ''
            if [ -n "${contract.etherscanApiKey}" ]; then
              echo "Verifying ${name} on Etherscan..."
              forge verify-contract \
                --chain-id $(cast chain-id --rpc-url "${config.ethereum-contracts.rpcUrl}") \
                --compiler-version $(jq -r '.compilerVersion' $DEPLOYMENT_DIR/${name}.json) \
                --constructor-args $(cast abi-encode "constructor(${lib.concatStringsSep "," (map (arg: "address") contract.constructorArgs)})" ${lib.concatStringsSep " " contract.constructorArgs}) \
                --etherscan-api-key "${contract.etherscanApiKey}" \
                $CONTRACT_ADDRESS \
                ${contract.path}:$(jq -r '.contractName' $DEPLOYMENT_DIR/${name}.json)
            else
              echo "Skipping verification: No Etherscan API key provided"
            fi
          ''}
        '';
      in
      {
        options.ethereum-contracts = lib.mkOption {
          type = types.submodule ethereumOpts;
          default = {};
          description = "Ethereum contracts deployment configuration";
        };
        
        config.apps = lib.mkIf (config.ethereum-contracts.contracts != {}) {
          deploy-ethereum-contracts.program = pkgs.writeShellApplication {
            name = "deploy-ethereum-contracts";
            runtimeInputs = with pkgs; [
              nodePackages.ethereum-cryptography
              jq
            ];
            text = ''
              # Ensure Foundry is installed
              if ! command -v forge &> /dev/null; then
                echo "Foundry not found. Installing..."
                ${pkgs.curl}/bin/curl -L https://foundry.paradigm.xyz | bash
                export PATH="$PATH:$HOME/.foundry/bin"
                foundryup
              fi
              
              # Create deployment directory
              DEPLOYMENT_DIR="$PWD/deployments"
              mkdir -p "$DEPLOYMENT_DIR"
              
              # Deploy contracts
              ${lib.concatStringsSep "\n" (lib.mapAttrsToList deployContract config.ethereum-contracts.contracts)}
              
              echo "All contracts deployed successfully. Deployment information saved to $DEPLOYMENT_DIR/"
            '';
          };
        };
      }
    );
  };
} 