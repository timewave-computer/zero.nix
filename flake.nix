{
  nixConfig = {
    extra-substituters = "https://timewave.cachix.org";
    extra-trusted-public-keys = ''
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
        ./flakeModules/default.nix
        ./nixosModules/default.nix
        ./packages/default.nix
      ];
      
      perSystem = { self', pkgs, system, lib, ... }: 
      let 
        # Import test functionality
        tests = import ./tests/run-tests.nix { 
          inherit pkgs; 
          self = self'; 
        };
      in {
        # Main development shell
        devShells.default = pkgs.mkShell {
          packages = [
            self'.packages.foundry-forge
            self'.packages.foundry-anvil
            self'.packages.foundry-cast
          ];
          
          shellHook = ''
            echo "Zero.nix development environment"
            echo "Ethereum tools available:"
            echo "  - forge: Ethereum smart contract development tool"
            echo "  - anvil: Local Ethereum development node"
            echo "  - cast: Ethereum transaction/call utility"
            echo ""
            echo "To test the Ethereum integration, try running:"
            echo "  anvil --help"
          '';
        };

        # Expose test shells
        devShells = tests.devShells // { inherit (self'.devShells) default; };
        
        # Expose test packages
        packages = lib.recursiveUpdate self'.packages tests.packages;
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    cosmos-nix.url = "github:timewave-computer/cosmos.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
    flake-utils.url = "github:numtide/flake-utils";
  };
}
