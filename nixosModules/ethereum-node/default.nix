# Main ethereum node module for zero.nix
# Provides systemd services for geth and lighthouse
{ zero-nix, ... }:
{ config, options, lib, pkgs, ... }:
let
  inherit (lib) types;
  
  cfg = config.services.ethereum;
  
  nodeNames = lib.attrNames cfg.nodes;
  
  getPort = port: portIndex: port + portIndex;
  
  defaultNodeAddressesModule = { name, ... }:
    let
      portIndex = lib.lists.findFirstIndex (x: x == name) null nodeNames;
      defaults = cfg.nodeDefaults;
    in
    {
      execution = {
        rpcPort = getPort defaults.execution.rpcPort portIndex;
        p2pPort = getPort defaults.execution.p2pPort portIndex;
      };
      consensus = {
        restPort = getPort defaults.consensus.restPort portIndex;
        p2pPort = getPort defaults.consensus.p2pPort portIndex;
      };
    };
  
  nodeOpts = {
    imports = [
      ./node-opts.nix
    ];
    _module.args = {
      inherit pkgs nodeNames;
    };
  };
  
  # Generate JWT secret for Engine API authentication
  mkJwtSecret = name: nodeCfg: {
    name = "ethereum-jwt-${name}";
    value = {
      description = "Generate JWT secret for ${name}";
      wantedBy = [ "multi-user.target" ];
      script = ''
        if [ ! -f "${nodeCfg.jwtSecret}" ]; then
          mkdir -p "$(dirname "${nodeCfg.jwtSecret}")"
          openssl rand -hex 32 > "${nodeCfg.jwtSecret}"
          chmod 600 "${nodeCfg.jwtSecret}"
        fi
      '';
      serviceConfig = {
        Type = "oneshot";
        User = "ethereum";
        Group = "ethereum";
        StateDirectory = "ethereum-node-${name}";
      };
    };
  };
  
  # Create geth execution client service
  mkGethService = name: nodeCfg:
    let
      gethCmd = "${zero-nix.packages.geth}/bin/geth";
      networkFlag = if nodeCfg.execution.network == "mainnet" then "" else "--${nodeCfg.execution.network}";
    in
    {
      name = "ethereum-execution-${name}";
      value = {
        description = "Geth execution client for ${name}";
        wantedBy = [ "multi-user.target" ];
        wants = [ "ethereum-jwt-${name}.service" ];
        after = [ "network.target" "ethereum-jwt-${name}.service" ];
        
        environment = {
          HOME = nodeCfg.execution.datadir;
        };
        
        script = ''
          ${gethCmd} ${networkFlag} \
            --datadir "${nodeCfg.execution.datadir}" \
            --http --http.addr "0.0.0.0" --http.port ${toString nodeCfg.execution.rpcPort} \
            --http.api "eth,net,web3" \
            --ws --ws.addr "0.0.0.0" --ws.port ${toString (nodeCfg.execution.rpcPort + 1)} \
            --ws.api "eth,net,web3" \
            --port ${toString nodeCfg.execution.p2pPort} \
            --syncmode ${nodeCfg.execution.syncMode} \
            --authrpc.addr "127.0.0.1" --authrpc.port ${toString (nodeCfg.execution.rpcPort + 100)} \
            --authrpc.jwtsecret "${nodeCfg.jwtSecret}" \
            --metrics --metrics.addr "127.0.0.1" --metrics.port ${toString (nodeCfg.execution.rpcPort + 200)}
        '';
        
        serviceConfig = {
          Type = "exec";
          User = "ethereum";
          Group = "ethereum";
          StateDirectory = "ethereum-node-${name}";
          WorkingDirectory = nodeCfg.execution.datadir;
        };
      };
    };
  
  # Create lighthouse consensus client service
  mkLighthouseService = name: nodeCfg:
    let
      lighthouseCmd = "${zero-nix.packages.lighthouse}/bin/lighthouse";
      networkFlag = if nodeCfg.consensus.network == "mainnet" then "mainnet" else nodeCfg.consensus.network;
      checkpointSyncArgs = lib.optionalString (nodeCfg.consensus.checkpointSyncUrl != null) 
        "--checkpoint-sync-url ${nodeCfg.consensus.checkpointSyncUrl}";
    in
    {
      name = "ethereum-consensus-${name}";
      value = {
        description = "Lighthouse consensus client for ${name}";
        wantedBy = [ "multi-user.target" ];
        wants = [ "ethereum-execution-${name}.service" ];
        after = [ "network.target" "ethereum-execution-${name}.service" ];
        
        environment = {
          HOME = nodeCfg.consensus.datadir;
        };
        
        script = ''
          ${lighthouseCmd} bn \
            --network ${networkFlag} \
            --datadir "${nodeCfg.consensus.datadir}" \
            --http --http-address "0.0.0.0" --http-port ${toString nodeCfg.consensus.restPort} \
            --port ${toString nodeCfg.consensus.p2pPort} \
            --execution-endpoint "http://127.0.0.1:${toString (nodeCfg.execution.rpcPort + 100)}" \
            --execution-jwt "${nodeCfg.jwtSecret}" \
            --metrics --metrics-address "127.0.0.1" --metrics-port ${toString (nodeCfg.consensus.restPort + 100)} \
            ${checkpointSyncArgs}
        '';
        
        serviceConfig = {
          Type = "exec";
          User = "ethereum";
          Group = "ethereum";
          StateDirectory = "ethereum-node-${name}";
          WorkingDirectory = nodeCfg.consensus.datadir;
        };
      };
    };
  
in
{
  options = {
    services.ethereum.nodeDefaults = lib.mkOption {
      type = types.submodule {
        _module.args.name = lib.mkForce "<name>";
        imports = [ nodeOpts ];
      };
      default = {};
    };
    
    services.ethereum.nodes = lib.mkOption {
      type = types.attrsOf (types.submodule {
        imports = [
          nodeOpts
          defaultNodeAddressesModule
        ] ++ options.services.ethereum.nodeDefaults.definitions;
      });
      default = {};
    };
  };
  
  config = {
    # Create ethereum user and group
    users.users.ethereum = {
      isSystemUser = true;
      group = "ethereum";
      home = "/var/lib/ethereum";
      createHome = true;
    };
    
    users.groups.ethereum = {};
    
    # Create systemd services
    systemd.services = 
      (lib.mapAttrs' mkJwtSecret cfg.nodes) //
      (lib.mapAttrs' mkGethService (lib.filterAttrs (n: v: v.enable && v.execution.enable) cfg.nodes)) //
      (lib.mapAttrs' mkLighthouseService (lib.filterAttrs (n: v: v.enable && v.consensus.enable) cfg.nodes));
    
    # Open firewall ports if requested
    networking.firewall.allowedTCPPorts = lib.flatten (
      lib.mapAttrsToList (n: v: lib.optionals v.openFirewall [
        v.execution.rpcPort
        v.execution.p2pPort
        v.consensus.restPort
        v.consensus.p2pPort
      ]) cfg.nodes
    );
  };
} 