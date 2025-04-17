{
  nixConfig = {
    extra-substituters = "https://timewave.cachix.org";
    extra-trusted-public-keys = ''
      timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
    '';
  };

  description = "Uploading valence_authorization contract to neutron and juno";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];
      perSystem = { lib, inputs', ... }: {
        upload-contracts = {
          networks.mainnet = {
            chainDefaults = { name, ... }: {
              contracts = {
                valence_authorization.package = inputs'.zero-nix.packages.valence-contracts-main;
                valence_base_account.package = inputs'.zero-nix.packages.valence-contracts-main;
              };
              chain-id = lib.mkDefault "${name}-1";
              max-fees = "1000000";
            };
            chains = {
              neutron = {
                chain-id = "neutron-1";
                node-address = "https://rpc-voidara.neutron-1.neutron.org";
                denom = "untrn";
              };
              juno = {
                chain-id = "juno-1";
                node-address = "https://juno-rpc.polkachu.com:443";
                denom = "ujuno";
              };
            };
          };
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zero-nix.url = "github:timewave-computer/zero.nix";
  };
}
