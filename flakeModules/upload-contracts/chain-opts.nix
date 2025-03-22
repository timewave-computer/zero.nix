{ name, lib, config, pkgs, ... }:
let
  inherit (lib) types;
  jsonFormat = pkgs.formats.json {};
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
      default = "${name}-contracts.yaml";
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
    contracts = lib.mkOption {
      type = types.attrsOf (types.submodule ({ config, ... }: {
        options.path = lib.mkOption {
          type = types.path;
        };
        options.initial-state = lib.mkOption {
          type = jsonFormat.type;
          apply = s: builtins.toJSON s;
          default = {};
        };
        options.instantiate = lib.mkOption {
          type = types.boolean;
          default = false;
          apply = x: if x then "1" else "0";
        };
      }));
      default = {};
    };
  };
};
