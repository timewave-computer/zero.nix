{ cosmos-nix, zero-nix, ... }:
{ config, options, lib, pkgs, ... }:
let
  inherit (lib) types;

  cfg = config.services.cosmos;

  tomlFormat = pkgs.formats.toml {};
  jsonFormat = pkgs.formats.json {};

  nodeNames = lib.attrNames cfg.nodes;

  getPort = addr: lib.toInt (lib.last (lib.splitString ":" addr));

  defaultNodeAddressesModule = { name, ... }:
    let
      portIndex = lib.lists.findFirstIndex (x: x == name) null nodeNames;
      iteratePort = addr:
        let
          splitAddr = lib.splitString ":" addr;
          port = lib.toInt (lib.last splitAddr);
          withoutPort = lib.take ((lib.length splitAddr) - 1) splitAddr;
        in
          lib.concatStringsSep ":" (withoutPort ++ [ (toString (port + portIndex)) ]);
      defaults = cfg.nodeDefaults;
    in
    {
      settings = {
        proxy_app = iteratePort defaults.settings.proxy_app;
        rpc.laddr = iteratePort defaults.settings.rpc.laddr;
        rpc.pprof_laddr = iteratePort defaults.settings.rpc.pprof_laddr;
        p2p.laddr = iteratePort defaults.settings.p2p.laddr;
      };
      appSettings = {
        grpc.address = iteratePort defaults.appSettings.grpc.address;
        api.address = iteratePort defaults.appSettings.api.address;
      };
    };

  defaultAddressesModule = {
    settings = {
      proxy_app = lib.mkDefault "tcp://127.0.0.1:26758";
      rpc.laddr = lib.mkDefault "tcp://0.0.0.0:25565";
      rpc.pprof_laddr = lib.mkDefault "0.0.0.0:6060";
      p2p.laddr = lib.mkDefault "tcp://0.0.0.0:26656";
    };

    appSettings = {
      grpc.address = lib.mkDefault "0.0.0.0:9090";
      api.address = lib.mkDefault "tcp://0.0.0.0:1517";
    };
  };

  nodeOpts = {
    imports = [
      (import ./node-opts.nix { inherit cosmos-nix; })
    ];
    _module.args = {
      inherit pkgs nodeNames;
    };
  };

  toml-merge =
    pkgs.writers.writePython3Bin "toml-merge"
      {
        libraries = with pkgs.python3Packages; [
          tomli-w
          mergedeep
        ];
      }
      (builtins.readFile ./toml-merge.py);

  mkSetupService = name: nodeCfg:
    let
      inherit (nodeCfg) command genesisSubcommand genesisAccounts chain-id denom;
      genesisFile = jsonFormat.generate "genesis.json" nodeCfg.genesisSettings;

      commonFlags = "--keyring-backend=test --home=$HOME";

      setupGenesisAccount = name: account: ''
        # redirected stdout and stderr to key file for ibc relayer to import
        # some chains like osmosisd output key json into stderr while others output to stdout
        echo "${account.mnemonic}" | ${command} keys add ${name} --recover --home="$HOME" \
          --keyring-backend=test --output=json > keys/${name}.json 2>&1

        ${command} ${genesisSubcommand} add-genesis-account ${commonFlags} \
          ${name} ${account.amount}${account.denom}
        ${lib.optionalString ((lib.toInt account.stakeAmount) > 0) ''
          ${command} ${genesisSubcommand} gentx ${name} ${account.stakeAmount}${account.denom} \
             ${commonFlags} --chain-id="${chain-id}"
        ''}
      '';
    in
      {
        name = "cosmos-setup-${name}";
        value = {
          description = "setup of ${name}";
          wantedBy = [ "multi-user.target" ];
          environment = {
            HOME = "%S/cosmos-node-${name}";
            GAHOME = "%S/cosmos-node-${name}";
          };
          path = with pkgs; [ jq gawk zero-nix.packages.upload-contract ];
          script = ''
            if [ ! -f $HOME/config/genesis.json ]; then
              mkdir -p keys
              ${command} init ${nodeCfg.moniker} --home="$HOME" --chain-id="${chain-id}"
              sed -i -E 's|"([a-z]*_?denom)": "[^"]+",|"\1": "${denom}",|' config/genesis.json

              ${lib.concatStringsSep "\n" (lib.mapAttrsToList setupGenesisAccount genesisAccounts)}

              ${if nodeCfg.isConsumer then ''
                ${command} add-consumer-section --home $HOME
              '' else ''
                ${command} ${genesisSubcommand} collect-gentxs --home="$HOME"
              ''}

              mv config/config.toml config/config.default.toml
              mv config/app.toml config/app.default.toml
              mv config/genesis.json config/genesis.default.json

              # Merge default genesis file with nixos genesis settings
              jq -s '.[0] * .[1]' \
                config/genesis.default.json ${genesisFile} > config/genesis.json
            fi
          '';
          serviceConfig = {
            WorkingDirectory = "%S/cosmos-node-${name}";
            StateDirectory = "cosmos-node-${name}";
            Type = "oneshot";
          };
        };
      };


  mkContractService = name: nodeCfg:
    let
      inherit (nodeCfg) command chain-id denom dataDir;
      rpcPort = toString (getPort nodeCfg.settings.rpc.laddr);

      uploadContract = label: contract: ''
        export COMMAND=${command}
        export CONTRACT_PATH=${contract.path}
        export CHAIN_ID=${chain-id}
        export ADMIN_ADDRESS="$ROOT_ADDRESS"
        export NODE_ADDRESS="http://localhost:${rpcPort}"
        export MAX_FEES="100000000000"
        export DENOM=${denom}
        export NODE_HOME="${dataDir}"
        export DATA_FILE="${dataDir}/contracts.yaml"
        export INSTANTIATE="1"
        export INITIAL_STATE='${contract.initial-state}'
        export GAS_MULTIPLIER="${toString nodeCfg.transactions.gas-multiplier}"
        upload-contract
      '';
    in
    {
      name = "cosmos-upload-contracts-${name}";
      value = {
        description = "uploading of contracts to ${name}";
        wantedBy = ["multi-user.target"];
        wants = [ "cosmos-node-${name}.service" ];
        after = ["network.target" "cosmos-node-${name}.service"];
        # %S/%N refers to $STATE_DIRECTORY, env vars aren't expanded in systemd config
        environment = {
          HOME = "%S/cosmos-node-${name}";
          GAHOME = "%S/cosmos-node-${name}";
        };
        path = with pkgs; [ jq gawk zero-nix.packages.upload-contract ];
        script = ''
          ROOT_ADDRESS=$(jq -r '.address' $HOME/keys/root.json)
          ${lib.concatStringsSep "\n" (lib.mapAttrsToList uploadContract nodeCfg.contracts)}
        '';
        serviceConfig = {
          WorkingDirectory = "%S/cosmos-node-${name}";
          StateDirectory = "cosmos-node-${name}";
          Type = "oneshot";
        };
      };
    };

  mkService = name: nodeCfg:
    let
      inherit (nodeCfg) command;
      mkArg = name: val: ''--${name}="${val}"'';
      args = lib.concatStringsSep " " (lib.mapAttrsToList mkArg nodeCfg.flags);
      configFile = tomlFormat.generate "config.toml" nodeCfg.settings;
      appConfigFile = tomlFormat.generate "app.toml" nodeCfg.appSettings;

      rpcPort = toString (getPort nodeCfg.settings.rpc.laddr);
    in
    {
      name = "cosmos-node-${name}";
      value = {
        description = "${name} daemon";
        wantedBy = ["multi-user.target"];
        after = ["network.target" "cosmos-setup-${name}.service" ];
        requires = [ "cosmos-setup-${name}.service" ];
        # %S/%N refers to $STATE_DIRECTORY, env vars aren't expanded in systemd config
        environment = {
          HOME = "%S/%N";
          GAHOME = "%S/%N";
        };
        path = with pkgs; [ jq curl netcat ];
        preStart = ''
          # Merge default config files with nixos settings
          ${lib.getExe toml-merge} config/config.default.toml ${configFile} > config/config.toml
          ${lib.getExe toml-merge} config/app.default.toml ${appConfigFile} > config/app.toml
        '';
        postStart =
          let
            statusUrl = "http://localhost:${rpcPort}/status";
            blockHeightAttr = ".result.sync_info.latest_block_height";
            getBlockHeight = "curl -s ${statusUrl} | jq ${blockHeightAttr} -r 2>/dev/null";
          in
          ''
            while ! nc -z localhost ${rpcPort}; do
              echo "waiting for rpc port to be open on ${rpcPort}"
              sleep 1
            done
            while [[ $(${getBlockHeight}) -le 0 ]]; do
              echo "waiting for first block to be created"
              sleep 1
            done
          '';
        serviceConfig = {
          WorkingDirectory = "%S/%N";
          StateDirectory = "cosmos-node-${name}";
          Type = "exec";
          ExecStart = "${command} start --home=\"%S/%N\" ${args}";
        } // lib.optionalAttrs nodeCfg.ephemeral {
          ExecStopPost = "${pkgs.coreutils}/bin/rm -rf %S/%N";
        };
      };
    };
in
{
  options = {
    services.cosmos.nodeDefaults = lib.mkOption {
      type = types.submodule {
        _module.args.name = lib.mkForce "<name>";
        imports = [
          nodeOpts
          defaultAddressesModule
        ];
      };
      default = {};
    };
    services.cosmos.nodes = lib.mkOption {
      type = types.attrsOf (types.submodule {
        imports = [
          nodeOpts
          defaultNodeAddressesModule
        ] ++ options.services.cosmos.nodeDefaults.definitions;
      });
      default = {};
    };
  };

  config = {
    # Initialize one root genesis account to ensure some staked tokens
    services.cosmos.nodeDefaults = { config, ... }: {
      genesisAccounts.root = {
        amount = lib.mkDefault "1000000000000000000000000000000000";
        # gentx for staking won't work in a consumer chain like neutron
        stakeAmount = lib.mkDefault (if config.isConsumer then "0" else "70000000000000");
      };
      appSettings = {
        api.enable = true;
        grpc-web.enable = false;
      };
    };
    systemd.services = (lib.mapAttrs' mkService cfg.nodes)
                       // (lib.mapAttrs' mkContractService (lib.filterAttrs (n: v: v.supportsContracts) cfg.nodes))
                       // (lib.mapAttrs' mkSetupService cfg.nodes);

    networking.firewall.allowedTCPPorts = lib.flatten (
      lib.mapAttrsToList
        (n: v: [ (getPort v.settings.rpc.laddr) (getPort v.appSettings.grpc.address) ])
        cfg.nodes
    );

  };
}
