{ config, options, lib, pkgs, ... }@args:
let
  inherit (lib) types;

  cfg = config.services.cosmos;

  tomlFormat = pkgs.formats.toml {};
  jsonFormat = pkgs.formats.json {};

  nodeNames = lib.attrNames cfg.nodes;
  nodeServices = lib.map (n: "cosmos-node-${n}.service") nodeNames;

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
      ./node-opts.nix
    ];
    _module.args = {
      inherit pkgs nodeNames;
    };
  };

  py-toml-merge =
    pkgs.writers.writePython3Bin "py-toml-merge"
      {
        libraries = with pkgs.python3Packages; [
          tomli-w
          mergedeep
        ];
      }
      ''
        import argparse
        from pathlib import Path
        from typing import Any
        import tomli_w
        import tomllib
        from mergedeep import merge
        parser = argparse.ArgumentParser(description="Merge multiple TOML files")
        parser.add_argument(
            "files",
            type=Path,
            nargs="+",
            help="List of TOML files to merge",
        )
        args = parser.parse_args()
        merged: dict[str, Any] = {}
        for file in args.files:
            with open(file, "rb") as fh:
                loaded_toml = tomllib.load(fh)
                merged = merge(merged, loaded_toml)
        print(tomli_w.dumps(merged))
      '';

  mkContractService = name: nodeCfg:
    let
      inherit (nodeCfg) command chain-id denom;
      rpcPort = toString (getPort nodeCfg.settings.rpc.laddr);
      commonFlags = "--keyring-backend=test --home=$HOME --node http://localhost:${rpcPort}";
      gasMultiplier = toString nodeCfg.transactions.gas-multiplier;

      uploadContract = label: contract:
        let
          instantiateContract = ''
            ${command} tx wasm instantiate $CODE_ID '${contract.initialState}' --yes ${commonFlags} --output=json \
              --admin $ROOT_ADDRESS --from $ROOT_ADDRESS --label "${label}" --chain-id ${chain-id} \
          '';
          storeContract = ''
            ${command} tx wasm store ${contract.path} --from $ROOT_ADDRESS --gas-adjustment ${gasMultiplier} \
              --gas auto --chain-id ${chain-id} ${commonFlags} --output json --yes \
          '';
          queryHash = "${command} query tx $TXHASH --node http://localhost:${rpcPort} --output json";
          queryContract = ''
            ${command} query wasm list-contract-by-code $CODE_ID --chain-id ${chain-id} \
              --node http://localhost:${rpcPort} --output json \
          '';
          extractFee = ''
            jq .raw_log | grep -oP 'required: [^0-9]*\K[0-9]+(\.[0-9]+)?${denom}' \
            | awk -F'${denom}' '{printf "%f${denom}\n", ($1*1.5)}' \
          '';
        in
        ''
          CONTRACT_HASH=$(sha256sum ${contract.path} | awk '{print $1}')
          CONTRACT_DIR=$HOME/contracts/${label}
          HASH_FILE=$CONTRACT_DIR/hash
          UPDATE_NEEDED=false
          if [[ -d "$CONTRACT_DIR" ]]; then
            echo "contract ${label} has already been created, checking to see if contract has changed from previous upload"
            if [[ -f "$HASH_FILE" && "$CONTRACT_HASH" == "$(cat "$HASH_FILE")" ]]; then
              echo "contract ${label} has remain unchanged, skipping"
            else
              UPDATE_NEEDED=true
            fi
          else
            UPDATE_NEEDED=true
          fi
          if [[ "$UPDATE_NEEDED" == true ]]; then
            echo "Starting upload of contract ${label}"

            mkdir -p $CONTRACT_DIR

            STORE_FEES=$(${storeContract} --fees 0.01${denom} | ${extractFee})
            echo "Found fees for storing contract to be $STORE_FEES"
            echo "storing contract"
            ${storeContract} --fees $STORE_FEES > $CONTRACT_DIR/store-output.json

            TXHASH=$(jq -r '.txhash' $CONTRACT_DIR/store-output.json)
            while ! ${queryHash}; do
              echo "waiting for tx hash $TXHASH for contract ${label} to be available"
              sleep 1
            done
            ${queryHash} > $CONTRACT_DIR/block-data.json
            CODE_ID=$(jq -r '.events[].attributes[] | select(.key == "code_id") | .value' $CONTRACT_DIR/block-data.json)
            echo "found code id to be $CODE_ID"

            INST_FEES=$(${instantiateContract} --fees 0.01${denom} | ${extractFee})
            echo "Found fees for instantiating contract to be $INST_FEES"
            echo "Instantiating contract"
            ${instantiateContract} --fees $INST_FEES > $CONTRACT_DIR/instantiate-output.json

            while ${queryContract} | jq -e '.contracts | length == 0'; do
              echo "waiting for contract address to be available"
              sleep 1
            done
            ${queryContract} > $CONTRACT_DIR/addresses.json

            echo $CODE_ID > $CONTRACT_DIR/code-id

            echo "Successfully uploaded ${label} contract with code id $CODE_ID"
            echo "$CONTRACT_HASH" > $CONTRACT_DIR/hash # create hash file to indicate success

            sleep 5 # prevent "account sequence mismatch" error
          fi
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
        path = with pkgs; [ jq gawk ];
        script = ''
          mkdir -p $HOME/contracts
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
      inherit (nodeCfg) command genesisSubcommand genesisAccounts chain-id denom;
      mkArg = name: val: ''--${name}="${val}"'';
      args = lib.concatStringsSep " " (lib.mapAttrsToList mkArg nodeCfg.flags);
      configFile = tomlFormat.generate "config.toml" nodeCfg.settings;
      appConfigFile = tomlFormat.generate "app.toml" nodeCfg.appSettings;
      genesisFile = jsonFormat.generate "genesis.json" nodeCfg.genesisSettings;

      rpcPort = toString (getPort nodeCfg.settings.rpc.laddr);

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
      name = "cosmos-node-${name}";
      value = {
        description = "${name} daemon";
        wantedBy = ["multi-user.target"];
        after = ["network.target"];
        # %S/%N refers to $STATE_DIRECTORY, env vars aren't expanded in systemd config
        environment = {
          HOME = "%S/%N";
          GAHOME = "%S/%N";
        };
        path = with pkgs; [ jq curl netcat ];
        preStart = ''
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

          # Merge default config files with nixos settings
          ${lib.getExe py-toml-merge} config/config.default.toml ${configFile} > config/config.toml
          ${lib.getExe py-toml-merge} config/app.default.toml ${appConfigFile} > config/app.toml
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
                       // (lib.mapAttrs' mkContractService cfg.nodes);

    networking.firewall.allowedTCPPorts = lib.flatten (
      lib.mapAttrsToList
        (n: v: [ (getPort v.settings.rpc.laddr) (getPort v.appSettings.grpc.address) ])
        cfg.nodes
    );

  };
}
