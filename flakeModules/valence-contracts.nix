{ zero-nix }:
{ lib, flake-parts-lib, ... }:
let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;

in
{
  _file = ./valence-contracts.nix;
  imports = [
    # Can't use zero-nix.flakeModules.upload-contracts, because it causes
    # infinite recursion since this module is used by zero.nix itself
    (import ./upload-contracts {
      inherit zero-nix;
      inherit (zero-nix.inputs) cosmos-nix;
    })
  ];

  options.perSystem = mkPerSystemOption (
    { config, system, options, ... }:
    {
      options.valence-contracts.upload = lib.mkEnableOption ''
        Setup all valence contracts from latest stable release to be uploaded.
      '';
      options.valence-contracts.builds = lib.mkOption {
        description = ''
          Valence contract builds to add to packages output.
        '';
        default = {};
        type = types.attrsOf (types.submodule ({ name, ... }: {
          options = {
            src = lib.mkOption {
              type = types.path;
              description = ''
                Source to build valence contracts from.
                Could be a flake input or the result of `builtins.fetchGit`.
              '';
            };
            version = lib.mkOption {
              type = types.str;
              default = name;
              defaultText = lib.literalExpression "\${name}";
              description = ''
                Valence protocol version thats being built.
                Only used to name resulting package.
              '';
            };
            contracts-dir = lib.mkOption {
              type = types.str;
              default = "contracts";
              description = ''
                Folder where contract packages are located.
                All cargo packages within folder will be built.
              '';
            };
            packages = lib.mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              defaultText = "null, which will cause all contracts found in folder specified by contracts-dir option to be built";
              description = ''
                Manually specified list of cargo packages to build contracts for.
                When specified, `contracts-dir` option will be ignored.
              '';
            };
            rust-version = lib.mkOption {
              type = types.str;
              default = "1.81.0";
              description = ''
                Rust version to build contracts with.
              '';
            };
          };
        }));
      };
      config = lib.mkMerge [
        (lib.mkIf config.valence-contracts.upload {
          upload-contracts.networkDefaults.chainDefaults = { config, ... }: {
            contracts = lib.mkMerge [
              # Contract paths are inferred based on name
              # but can be manually set with the `path` option within each contract
              # For example: valence_processor.path = ${valence-contracts-main}/valence_processor.wasm;
              {
                valence_processor = {};
                valence_base_account = {};
                valence_forwarder_library = {};
                valence_splitter_library = {};
                valence_reverse_splitter_library = {};
                valence_astroport_lper = {};
                valence_astroport_withdrawer = {};
                valence_generic_ibc_transfer_library = {};
              }
              (lib.mkIf (config.package.pname == "neutron") {
                # All contracts that are specific to neutron
                valence_authorization = {};
                valence_program_registry = {};
                valence_drop_liquid_staker = {};
                valence_drop_liquid_unstaker = {};
                valence_neutron_ibc_transfer_library = {};
              })
            ];
          };
        })
        {
          packages = lib.mapAttrs' (name: buildAttrs: {
            name = "valence-contracts-${buildAttrs.version}";
            value = zero-nix.tools.${system}.buildValenceContracts buildAttrs;
          }) config.valence-contracts.builds;
        }
      ];
    });
}
