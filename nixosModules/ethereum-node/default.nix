{ config, lib, pkgs, ... }:

let
  cfg = config.services.ethereum;

  # Install Foundry using foundryup
  installFoundry = pkgs.writeShellScriptBin "install-foundry" ''
    if ! command -v foundryup &> /dev/null; then
      echo "Installing foundryup..."
      ${pkgs.curl}/bin/curl -L https://foundry.paradigm.xyz | bash
    fi
    
    # Source the environment to get foundryup in path
    source "$HOME/.foundry/bin/foundryup" 2>/dev/null || true
    
    # Run foundryup to install the latest stable version of Foundry
    export PATH="$PATH:$HOME/.foundry/bin"
    foundryup
  '';
in
{
  options = {
    services.ethereum = {
      enable = lib.mkEnableOption "Ethereum node with Foundry tools";
      
      nodes = lib.mkOption {
        type = lib.types.attrsOf (lib.types.submodule {
          options = {
            enable = lib.mkEnableOption "this Ethereum node instance";
            
            dataDir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/ethereum-node";
              description = "Directory to store Ethereum node data";
            };
            
            networkId = lib.mkOption {
              type = lib.types.int;
              default = 1337;
              description = "Ethereum network/chain ID";
            };
            
            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "Host interface to bind to";
            };
            
            port = lib.mkOption {
              type = lib.types.port;
              default = 8545;
              description = "RPC port to listen on";
            };
            
            blockTime = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              description = "Block time in seconds (null means instant mining)";
            };
            
            accounts = lib.mkOption {
              type = lib.types.listOf (lib.types.submodule {
                options = {
                  balance = lib.mkOption {
                    type = lib.types.str;
                    default = "10000000000000000000000";
                    description = "Initial balance in wei";
                  };
                  privateKey = lib.mkOption {
                    type = lib.types.nullOr lib.types.str;
                    default = null;
                    description = "Private key (leave null for auto-generation)";
                  };
                };
              });
              default = [];
              description = "Pre-funded accounts configuration";
            };
            
            extraArgs = lib.mkOption {
              type = lib.types.listOf lib.types.str;
              default = [];
              description = "Additional arguments to pass to anvil";
            };
          };
        });
        default = {};
        description = "Ethereum node configurations";
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.nodes != {}) {
    environment.systemPackages = [
      installFoundry
      pkgs.nodejs
      pkgs.git
      pkgs.curl
    ];
    
    systemd.services = lib.mapAttrs' (name: nodeCfg: 
      lib.nameValuePair "ethereum-node-${name}" {
        description = "Ethereum node (${name}) using Foundry's Anvil";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        
        path = [ "/root/.foundry/bin" ];
        
        preStart = ''
          ${installFoundry}/bin/install-foundry
          mkdir -p ${nodeCfg.dataDir}
        '';
        
        script = let
          blockTimeArg = if nodeCfg.blockTime != null then "--block-time ${toString nodeCfg.blockTime}" else "";
          accountArgs = lib.concatMapStrings (acc: 
            lib.optionalString (acc.privateKey != null) " --private-key ${acc.privateKey}"
          ) nodeCfg.accounts;
        in ''
          exec anvil \
            --host ${nodeCfg.host} \
            --port ${toString nodeCfg.port} \
            --chain-id ${toString nodeCfg.networkId} \
            ${blockTimeArg} \
            ${accountArgs} \
            ${lib.escapeShellArgs nodeCfg.extraArgs}
        '';
        
        serviceConfig = {
          Restart = "always";
          RestartSec = "10s";
          StateDirectory = "ethereum-node-${name}";
          WorkingDirectory = nodeCfg.dataDir;
          User = "root"; # For simplicity, could be more restricted
        };
      }
    ) (lib.filterAttrs (_: nodeCfg: nodeCfg.enable) cfg.nodes);
  };
} 