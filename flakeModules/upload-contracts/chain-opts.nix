{ name, lib, config, pkgs, options, data-dir, ... }:
let
  inherit (lib) types;
  jsonFormat = pkgs.formats.json {};

  contractOpts = { name, config, ... }: {
    options.package = lib.mkOption {
      type = types.package;
    };
    options.path = lib.mkOption {
      type = types.path;
      default = "${config.package}/${name}.wasm";
    };
    options.initial-state = lib.mkOption {
      type = jsonFormat.type;
      apply = s: builtins.toJSON s;
      default = {};
    };
    options.instantiate = lib.mkOption {
      type = types.bool;
      default = false;
      apply = x: if x then "1" else "0";
    };
    options.source = lib.mkOption {
      type = types.str;
      default = config.package.src.rev or config.path;
    };
  };
in
{
  options = {
    node-address = lib.mkOption {
      type = types.str;
      default = "";
    };
    max-fees = lib.mkOption {
      type = types.str;
      default = "";
    };
    denom = lib.mkOption {
      type = types.str;
      default = "";
    };
    chain-id = lib.mkOption {
      type = types.str;
      default = "";
    };
    admin-address = lib.mkOption {
      type = types.str;
      default = "";
    };
    package = lib.mkOption {
      type = types.package;
    };
    command = lib.mkOption {
      type = types.path;
      default = lib.getExe config.package;
    };
    data-file = lib.mkOption {
      type = types.str;
      default = "${data-dir}/${name}.yaml";
    };
    gas-multiplier = lib.mkOption {
      type = types.float;
      default = 1.5;
      apply = toString;
    };
    from-address = lib.mkOption {
      type = types.str;
      default = config.adminAddress or "";
    };
    keyring-backend = lib.mkOption {
      type = types.str;
      default = "test";
    };
    contractDefaults = lib.mkOption {
      type = types.submodule {
        _module.args.name = lib.mkForce "<name>";
        imports = [ contractOpts ];
      };
    };
    contracts = lib.mkOption {
      type = types.attrsOf (types.submodule {
        imports = [ contractOpts ]
          ++ options.contractDefaults.definitions;
      });
      default = {};
    };
  };
}
