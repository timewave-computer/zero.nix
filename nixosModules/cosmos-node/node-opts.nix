{ cosmos-nix, ... }:
{ name, lib, pkgs, nodeNames, config, ... }:
let
  inherit (lib) types;

  mnemonics = import ./mnemonics.nix;

  tomlFormat = pkgs.formats.toml {};
  jsonFormat = pkgs.formats.json {};

  genesisAccountNames = lib.attrNames config.genesisAccounts;
  genesisAccountOpts = { name, ... }:
    let
      index = lib.lists.findFirstIndex (x: x == name) null genesisAccountNames;
    in
    {
      options = {
        amount = lib.mkOption {
          default = "0";
          type = types.str;
        };
        mnemonic = lib.mkOption {
          type = types.str;
          default = lib.elemAt mnemonics index;
        };
        stakeAmount = lib.mkOption {
          default = "0";
          type = types.str;
        };
        denom = lib.mkOption {
          type = types.str;
          default = config.denom;
        };
      };
    };

  gasPriceOpts = {
    options.price = lib.mkOption {
      type = types.float;
      default = 0.0;
    };
    options.denom = lib.mkOption {
      type = types.str;
      default = config.denom;
    };
  };
in
{
  config = {
    settings = {
      app_state = {
        provider.params.template_client.trusting_period = lib.mkDefault config.trusting-period;
      };
    };
    appSettings = {
      minimum-gas-prices = with config.minimum-gas-price; lib.mkDefault "${toString price}${denom}";
    };
  };
  options = {
    moniker = lib.mkOption {
      type = types.str;
      default = name;
      defaultText = "\${name}";
    };
    chain-id = lib.mkOption {
      type = types.str;
    };
    isConsumer = lib.mkOption {
      type = types.bool;
      default = false;
    };
    # consumer-link = lib.mkOption {
    #   type = types.nullOr (types.enum nodeNames);
    #   default = null;
    # };
    denom = lib.mkOption {
      type = types.str;
      default = "stake";
    };
    bech32-prefix = lib.mkOption {
      type = types.str;
      default = "cosmos";
    };
    minimum-gas-price = lib.mkOption {
      type = types.submodule gasPriceOpts;
      default = {};
    };
    trusting-period = lib.mkOption {
      type = types.str;
      default = "336h";
    };
    transactions.gas-price = lib.mkOption {
      type = types.submodule gasPriceOpts;
      default = {
        price = lib.mkDefault (config.minimum-gas-price.price * 220);
      };
    };
    transactions.gas-multiplier = lib.mkOption {
      type = types.float;
      default = 1.5;
    };
    package = lib.mkOption {
      type = types.package;
      default = cosmos-nix.packages.${name};
    };
    command = lib.mkOption {
      type = types.path;
      default = lib.getExe config.package;
    };
    settings = lib.mkOption {
      type = types.submodule {
        freeformType = tomlFormat.type;
      };
      default = {};
      description = ''
        settings to override in config.toml
      '';
    };
    appSettings = lib.mkOption {
      type = types.submodule {
        freeformType = tomlFormat.type;
      };
      default = {};
      description = ''
        settings to override in app.toml
      '';
    };
    genesisSettings = lib.mkOption {
      type = types.submodule {
        freeformType = jsonFormat.type;
      };
      default = {};
      description = ''
        settings to override in genesis.json
      '';
    };
    flags = lib.mkOption {
      type = types.attrsOf types.str;
      default = {};
      # apply = x: default // x;
      description = "command line flags to pass chain node command";
    };
    genesisSubcommand = lib.mkOption {
      type = types.str;
      default = "";
      example = "genesis";
    };
    dataDir = lib.mkOption {
      type = types.path;
      default = "/var/lib/cosmos-node-${name}";
    };
    ephemeral = lib.mkEnableOption ''
      destruction of nodes data on service stop
    '';
    genesisAccounts = lib.mkOption {
      default = {};
      type = types.attrsOf (types.submodule genesisAccountOpts);
    };
    contracts = lib.mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options.path = lib.mkOption {
          type = types.path;
        };
        options.initialState = lib.mkOption {
          type = jsonFormat.type;
          apply = s: builtins.toJSON s;
          default = {};
        };
      }));
      default = {};
    };
  };
}
