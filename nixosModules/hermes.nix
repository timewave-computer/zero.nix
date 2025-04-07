{
  cosmos-nix
}:
# Module starts here
{ config, lib, pkgs, ... }:
let
  cosmosCfg = config.services.cosmos;
  cfg = cosmosCfg.hermes;
  nodes = cosmosCfg.nodes;

  command = lib.getExe cfg.package;

  tomlFormat = pkgs.formats.toml {};
  configFile = tomlFormat.generate "config.toml" cfg.settings;

  nodeNames = lib.attrNames cosmosCfg.nodes;
  nodeServices = lib.map (n: "cosmos-node-${n}.service") nodeNames;

  chainPairs = lib.filter (x: x.a != x.b) (lib.cartesianProduct rec {
    a = nodeNames; b = nodeNames;
  });

  createChannelCommand = set:
    let
      a = nodes.${set.a}.chain-id;
      b = nodes.${set.b}.chain-id;
    in
    ''
      if ${command} --json query channels --chain ${b} --counterparty-chain ${a} \
        | jq -es '.[2].result | length == 0'; then
        ${command} create channel --yes --a-chain ${a} --b-chain ${b} \
          --a-port transfer --b-port transfer --new-client-connection
      else
        echo "channel already exists between chains ${a} and ${b}, skipping"
      fi
    '';

  importKeyCommand = _: nodeCfg:
    let
      inherit (nodeCfg) dataDir chain-id;
    in
    ''
      if [ -f ${dataDir}/keys/hermes.json ]; then
        if [ ! -f .hermes/keys/${chain-id}/keyring-test/wallet.json ]; then
          echo "${nodeCfg.genesisAccounts.hermes.mnemonic}" \
            | ${command} keys add --chain ${chain-id} --mnemonic-file /dev/stdin
        else
          echo "key already imported for chain ${chain-id}, skipping import"
        fi
      else
        echo "key at ${dataDir}/keys/hermes.json for hermes user not found for chain ${chain-id}"
      fi
    '';

  createDefaultChainSettings = name:
    let
      nodeCfg = nodes.${name};
      getPort = addr: lib.last (lib.splitString ":" addr);
      rpcPort = getPort nodeCfg.settings.rpc.laddr;
    in lib.mapAttrs (_: val: lib.mkDefault val) {
      id = nodeCfg.chain-id;
      type = "CosmosSdk";
      rpc_addr = "http://localhost:${rpcPort}";
      grpc_addr = "http://localhost:${getPort nodeCfg.appSettings.grpc.address}";
      event_source = { mode = "push"; url = "ws://localhost:${rpcPort}/websocket"; batch_delay = "200ms"; };
      rpc_timeout = "15s";
      trusted_node = true;
      account_prefix = nodeCfg.bech32-prefix;
      key_name = "wallet";
      store_prefix = "ibc";
      gas_price = nodeCfg.transactions.gas-price;
      gas_multiplier = nodeCfg.transactions.gas-multiplier;
      trusting_period = nodeCfg.trusting-period;
      default_gas = 1000000;
      max_gas = 10000000;
      max_msg_num = 30;
      max_tx_size = 2097152;
      clock_drift = "5s";
      max_block_time = "30s";
      trust_threshold = { numerator = "2"; denominator = "3"; };
      ccv_consumer_chain = nodeCfg.isConsumer;
    };
in
{
  options = {
    services.cosmos.hermes = {
      enable = lib.mkEnableOption "hermes relayer for all nodes";
      package = lib.mkPackageOption cosmos-nix.packages "hermes" {
        pkgsText = "cosmos-nix.packages";
      };
      settings = lib.mkOption {
        type = tomlFormat.type;
        default = {};
      };
    };
  };

  config = {
    services.cosmos.nodeDefaults.genesisAccounts = {
      hermes = {
        amount = "1000000000000";
      };
    };
    services.cosmos.hermes.settings = lib.mkDefault {
      global.log_level = "info";
      mode = {
        clients = {
          enabled = true;
          refresh = true;
          misbehaviour = true;
        };
        connections.enabled = true;
        channels.enabled = true;
        packets.enabled = true;
      };
      chains = lib.map createDefaultChainSettings nodeNames;
    };
    systemd.services.hermes-channels-setup = {
      description = "hermes relayer setup";
      wantedBy = ["multi-user.target"];
      after = ["network.target" "hermes.service" ];
      wants = [ "hermes.service" ];
      environment.HOME = "%S/hermes";
      path = with pkgs; [ jq ];
      script = ''
        ${lib.concatStringsSep "\n" (lib.map createChannelCommand chainPairs)}
      '';
      serviceConfig = {
        WorkingDirectory = "%S/hermes";
        StateDirectory = "hermes";
        Type = "oneshot";
      };
    };
    systemd.services.hermes = {
      description = "hermes relayer";
      wantedBy = ["multi-user.target"];
      after = ["network.target" ] ++ nodeServices;
      wants = nodeServices;
      environment.HOME = "%S/%N";
      preStart = ''
        mkdir -p .hermes
        ln -fs ${configFile} .hermes/config.toml
        ${lib.concatStringsSep "\n" (lib.mapAttrsToList importKeyCommand cosmosCfg.nodes)}
      '';
      serviceConfig = {
        WorkingDirectory = "%S/%N";
        StateDirectory = "hermes";
        Type = "exec";
        ExecStart = "${command} start";
      };
    };
  };
}
