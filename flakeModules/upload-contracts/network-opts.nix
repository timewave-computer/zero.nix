{ cosmos-nix, pkgs }:
{name, config, lib, ...}@args:
let
  inherit (lib) types;

  chainOpts = {
    imports = [
      (import ./chain-opts.nix {
        inherit cosmos-nix;
      })
      ];
    _module.args = {
      inherit pkgs;
    };
  };
in
{
  options.data-dir = lib.mkOption {
    description = ''
      where to store data about contracts
    '';
    default = "${args.name}-contracts";
    type = types.str;
  };
  options.program-manager-chains-toml = lib.mkOption {
    type = types.nullOr types.path;
    default = null;
  };
  options.chains = lib.mkOption {
    description = ''
      Chains to upload contracts to
    '';

    type = types.attrsOf (types.submodule {
      _module.args = { inherit (args.config) data-dir; };
      imports = [
        chainOpts
      ] ++ args.options.chainDefaults.definitions;
    });

    default = { };
  };
  options.chainDefaults = lib.mkOption {
    type = types.submodule {
      _module.args.name = lib.mkForce "<name>";
      _module.args = { inherit (args) data-dir; };
      imports = [ chainOpts ];
    };
    default = {};
    description = ''
      Default settings for all chains
    '';
  };
  config.chains =
    let
      programManagerConfig = builtins.fromTOML
        (builtins.readFile config.program-manager-chains-toml);
    in
      lib.mkIf (config.program-manager-chains-toml != null) (lib.mapAttrs (name: chainConfig: {
        node-address = chainConfig.rpc;
        denom = chainConfig.gas_denom;
        chain-id = chainConfig.chain_id;
      }) programManagerConfig.chains);
}
