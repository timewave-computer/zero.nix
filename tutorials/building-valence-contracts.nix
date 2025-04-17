{
  nixConfig = {
    extra-substituters = "https://timewave.cachix.org";
    extra-trusted-public-keys = ''
      timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
    '';
  };

  description = "Package for valence-protocol contracts.";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
      ];
      perSystem = { system, ... }: {
        valence-contracts.builds = {
          main = {
            version = "main";
            src = inputs.valence-contracts-main;
          };
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
    zero-nix.url = "github:timewave-computer/zero.nix";
    valence-contracts-main.url = "github:timewave-computer/valence-protocol";
    valence-contracts-main.flake = false;
  };
}
