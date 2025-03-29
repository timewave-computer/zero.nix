{ lib, ... }:
{
  perSystem = {
    config = {
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
    };
  };
}
