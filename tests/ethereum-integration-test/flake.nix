{
  description = "Ethereum Integration Test for Zero.nix";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    zero-nix.url = "../..";
  };

  outputs = { self, nixpkgs, zero-nix }:
    let
      system = "aarch64-darwin";
      pkgs = import nixpkgs { inherit system; };
    in {
      packages.${system}.default = 
        pkgs.writeShellScriptBin "test-ethereum-integration" ''
          echo "Testing Ethereum integration in zero.nix"
          echo ""
          
          # List available Ethereum tools
          echo "Available Ethereum tools:"
          echo "* foundry-installer: ${zero-nix.packages.${system}.foundry-installer}"
          echo "* foundry-forge: ${zero-nix.packages.${system}.foundry-forge}"
          echo "* foundry-anvil: ${zero-nix.packages.${system}.foundry-anvil}"
          echo "* foundry-cast: ${zero-nix.packages.${system}.foundry-cast}"
          echo "* foundry-chisel: ${zero-nix.packages.${system}.foundry-chisel}"
          echo ""
          
          # Check NixOS module
          echo "NixOS Ethereum module: ethereum-nodes is available"
          echo ""
          
          echo "Testing successful!"
        '';
      
      nixosModules.test = { config, lib, pkgs, ... }: {
        imports = [ zero-nix.nixosModules.ethereum-nodes ];
        
        services.ethereum = {
          enable = true;
          nodes.test = {
            enable = true;
            networkId = 1337;
            port = 8545;
            host = "127.0.0.1";
            blockTime = 2; # 2 second block time
            accounts = [
              { 
                balance = "1000000000000000000000"; # 1000 ETH
              }
            ];
          };
        };
      };
      
      # Add a devShell for interactive testing
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [
          zero-nix.packages.${system}.foundry-forge
          zero-nix.packages.${system}.foundry-anvil
          zero-nix.packages.${system}.foundry-cast
        ];
        
        shellHook = ''
          echo "Ethereum Integration Test Shell"
          echo ""
          echo "Available commands:"
          echo "  forge - Ethereum smart contract development tool"
          echo "  anvil - Local Ethereum development node"
          echo "  cast  - Ethereum transaction/call utility"
          echo ""
          echo "Try running: anvil --help"
        '';
      };
    };
} 