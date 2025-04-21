{ cosmos-nix }:
{ name, lib, config, pkgs, options, data-dir, ... }:
let
  inherit (lib) types;
  jsonFormat = pkgs.formats.json {};

  contractOpts = { name, config, ... }: {
    options.package = lib.mkOption {
      type = types.package;
      description = ''
        Package where contract is stored.
        Only used to automatically set `path` and `source` options.
      '';
    };
    options.path = lib.mkOption {
      type = types.path;
      default = "${config.package}/${name}.wasm";
      defaultText = lib.literalExpression ''
        "''${package}/''${name}.wasm"
      '';
      description = ''
        Location of contract.
      '';
    };
    options.initial-state = lib.mkOption {
      type = jsonFormat.type;
      apply = s: builtins.toJSON s;
      default = {};
      description = ''
        Initial state to pass to contract when instantiating.
        Only used if `instantiat` is also set.
      '';
    };
    options.instantiate = lib.mkOption {
      type = types.bool;
      default = false;
      apply = x: if x then "1" else "0";
      description = ''
        Whether or not to instantiate contract.
      '';
    };
    options.source = lib.mkOption {
      type = types.str;
      default = config.package.src.rev or "";
      defaultText = lib.literalExpression ''
        `package.src.rev` if it exists, otherwise absolute path of contract
      '';
      description = ''
        Text to indicate where contract is sourced from. Could be a git revision, url, or local path.
      '';
    };
  };
in
{
  options = {
    node-address = lib.mkOption {
      type = types.str;
      default = "";
      description = ''
        RPC address of node to use for all chain operations.
      '';
    };
    max-fees = lib.mkOption {
      type = types.str;
      default = "";
      example = "1000000";
      description = ''
        Maximum fees allowed for any transaction.
      '';
    };
    denom = lib.mkOption {
      type = types.str;
      default = "";
      example = "uatom";
      description = ''
        Denom to use when submitting transactions on chain.
      '';
    };
    chain-id = lib.mkOption {
      type = types.str;
      default = "";
      description = ''
        Unique chain ID.
      '';
    };
    admin-address = lib.mkOption {
      type = types.str;
      default = "";
      description = ''
        Admin address to use for contracts;
      '';
    };
    package = lib.mkOption {
      type = types.package;
      default = cosmos-nix.packages.${pkgs.system}.${name};
      defaultText = lib.literalExpression ''
        cosmos-nix.packages.''${name}
      '';
      description = ''
        Package with node command for chain.
      '';
    };
    command = lib.mkOption {
      type = types.path;
      default =
        lib.assertMsg
          (config.package ? meta.mainProgram)
          ''
            The package option has no meta.mainProgram, so the chain binary cannot be inferred.
            Please set the command option with the exact path to the chain node.
            For example, "''${cosmos-nix.packages.gaia}/bin/gaiad".
          ''
          (lib.getExe config.package)
          ;
      defaultText = lib.literalExpression ''
        "''${package}/bin/''${package.meta.mainProgram}"
      '';
      description = ''
        Chain command to use for all operations.
      '';
    };
    data-file = lib.mkOption {
      type = types.str;
      default = "${data-dir}/${name}.yaml";
      defaultText = lib.literalExpression ''
        "''${data-dir}/''${name}.yaml"
      '';
      description = ''
        File where data about uploaded contracts will be stored.
      '';
    };
    gas-multiplier = lib.mkOption {
      type = types.float;
      default = 1.5;
      apply = toString;
      description = ''
        This number will be multiplied to the estimated gas computed for any transaction.
      '';
    };
    from-address = lib.mkOption {
      type = types.str;
      default = config.admin-address or "";
      defaultText = lib.literalExpression "admin-address";
      description = ''
        The account that transactions should be sent from.
        The private key for this account will need to be available in the
        keyring specified in the `keyring` option.
      '';
    };
    keyring-backend = lib.mkOption {
      type = types.str;
      default = "test";
      description = ''
        Keyring backend to use.
      '';
    };
    contract-defaults = lib.mkOption {
      type = types.deferredModule;
      default = {};
      description = ''
        Default settings to merge into all contracts.
      '';
    };
    contracts = lib.mkOption {
      type = types.attrsOf (types.submodule {
        imports = [ contractOpts config.contract-defaults ];
      });
      default = {};
      description = ''
        Contracts to upload to this chain.
      '';
    };
  };
}
