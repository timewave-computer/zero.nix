{
  nixConfig = {
    substituters = "https://timewave.cachix.org";
    trusted-public-keys = ''
      timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
    '';
  };

  description = "A nix based factory for creating chains";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      imports = [
        ./nixosModules/default.nix
      ];
    };

  inputs = {
    # Nix Inputs
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    cosmos-nix.url = "github:timewave-computer/cosmos.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };
}
