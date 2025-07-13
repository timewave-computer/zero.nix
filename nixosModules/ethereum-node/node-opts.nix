# Node options for ethereum nodes
# Provides configuration options for geth and lighthouse
{ name, lib, pkgs, nodeNames, config, options, ... }:
let
  inherit (lib) types;
  
  tomlFormat = pkgs.formats.toml {};
  jsonFormat = pkgs.formats.json {};
  
  executionClientOpts = {
    options = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the execution client";
      };
      
      client = lib.mkOption {
        type = types.enum [ "geth" ];
        default = "geth";
        description = "Which execution client to use";
      };
      
      network = lib.mkOption {
        type = types.enum [ "mainnet" "goerli" "sepolia" "holesky" ];
        default = "mainnet";
        description = "Ethereum network to connect to";
      };
      
      datadir = lib.mkOption {
        type = types.path;
        default = "/var/lib/ethereum-node-${name}/execution";
        description = "Data directory for execution client";
      };
      
      rpcPort = lib.mkOption {
        type = types.port;
        default = 8545;
        description = "HTTP RPC port";
      };
      
      p2pPort = lib.mkOption {
        type = types.port;
        default = 30303;
        description = "P2P networking port";
      };
      
      syncMode = lib.mkOption {
        type = types.enum [ "snap" "full" ];
        default = "snap";
        description = "Synchronization mode";
      };
    };
  };
  
  consensusClientOpts = {
    options = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the consensus client";
      };
      
      client = lib.mkOption {
        type = types.enum [ "lighthouse" ];
        default = "lighthouse";
        description = "Which consensus client to use";
      };
      
      network = lib.mkOption {
        type = types.enum [ "mainnet" "goerli" "sepolia" "holesky" ];
        default = "mainnet";
        description = "Ethereum network to connect to";
      };
      
      datadir = lib.mkOption {
        type = types.path;
        default = "/var/lib/ethereum-node-${name}/consensus";
        description = "Data directory for consensus client";
      };
      
      restPort = lib.mkOption {
        type = types.port;
        default = 5052;
        description = "REST API port";
      };
      
      p2pPort = lib.mkOption {
        type = types.port;
        default = 9000;
        description = "P2P networking port";
      };
      
      checkpointSyncUrl = lib.mkOption {
        type = types.nullOr types.str;
        default = null;
        description = "Checkpoint sync URL for faster sync";
      };
    };
  };
  
in
{
  options = {
    enable = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Whether to enable this ethereum node";
    };
    
    execution = lib.mkOption {
      type = types.submodule executionClientOpts;
      default = {};
      description = "Execution client configuration";
    };
    
    consensus = lib.mkOption {
      type = types.submodule consensusClientOpts;
      default = {};
      description = "Consensus client configuration";
    };
    
    jwtSecret = lib.mkOption {
      type = types.path;
      default = "/var/lib/ethereum-node-${name}/jwt.hex";
      description = "JWT secret file path for Engine API authentication";
    };
    
    dataDir = lib.mkOption {
      type = types.path;
      default = "/var/lib/ethereum-node-${name}";
      description = "Base data directory for the node";
    };
    
    openFirewall = lib.mkOption {
      type = types.bool;
      default = false;
      description = "Whether to open firewall ports";
    };
  };
} 