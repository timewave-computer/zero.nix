{
  description = "Ethereum node deployment using zero.nix";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://timewave.cachix.org";
  nixConfig.extra-trusted-public-keys = ''
    timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
  '';

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zero-nix.url = "github:timewave-computer/zero.nix";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
      
      flake = {
        nixosConfigurations = inputs.nixpkgs.lib.genAttrs systems (system:
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              inputs.zero-nix.nixosModules.ethereum-node
              {
                # Basic system configuration
                boot.isContainer = true;
                system.stateVersion = "23.11";
                networking.hostName = "ethereum-node";
                
                # Ethereum node configuration
                services.ethereum.nodes.mainnet = {
                  execution = {
                    network = "mainnet";
                    syncMode = "snap";
                  };
                  consensus = {
                    network = "mainnet";
                    checkpointSyncUrl = "https://mainnet.checkpoint.sigp.io";
                  };
                  openFirewall = true;
                };
                
                # Disable systemd-resolved for container compatibility
                systemd.services.systemd-resolved.enable = false;
                networking.useHostResolvConf = true;
              }
            ];
          });
      };
    };
} 