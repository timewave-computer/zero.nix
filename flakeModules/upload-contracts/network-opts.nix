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
    default = "${args.name}-contracts";
    defaultText = lib.literalExpression ''
      "''${name}-contracts";
    '';
    type = types.str;
    description = ''
      Folder where data about uploaded contracts should be stored.
    '';
  };
  options.program-manager-chains-toml = lib.mkOption {
    type = types.nullOr types.path;
    default = null;
    description = ''
      Chains.toml file in format used for valence program manager
      to pull default chain information from.
    '';
  };
  options.chains = lib.mkOption {
    description = ''
      Chains to upload contracts to.
    '';

    type = types.attrsOf (types.submodule {
      _module.args = { inherit (args.config) data-dir; };
      imports = [
        chainOpts
        args.config.chain-defaults
      ];
    });

    default = { };
  };
  options.chain-defaults = lib.mkOption {
    type = types.deferredModule;
    default = {};
    description = ''
      Default settings for all chains.
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
