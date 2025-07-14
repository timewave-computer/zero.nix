{
  description = "Ethereum development environment using zero.nix";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://timewave.cachix.org";
  nixConfig.extra-trusted-public-keys = ''
    timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
  '';

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    flake-parts.url = "github:hercules-ci/flake-parts";
    devshell.url = "github:numtide/devshell";
    zero-nix.url = "github:timewave-computer/zero.nix";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
        inputs.zero-nix.flakeModules.ethereum-development
      ];

      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        pkgs,
        inputs',
        ...
      }: {
        # Enable the ethereum development environment
        ethereum-development.enable = true;
        ethereum-development.network = "sepolia";
      };
    };
} 