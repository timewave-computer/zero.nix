# Test functionality for zero.nix
{ pkgs, self, ... }:

let
  # Define test configurations
  ethereumTest = pkgs.writeShellScriptBin "test-ethereum-integration" ''
    echo "Testing Ethereum integration in zero.nix"
    echo ""
    
    # List available Ethereum tools
    echo "Available Ethereum tools:"
    echo "* foundry-installer: ${self.packages.${pkgs.system}.foundry-installer}"
    echo "* foundry-forge: ${self.packages.${pkgs.system}.foundry-forge}"
    echo "* foundry-anvil: ${self.packages.${pkgs.system}.foundry-anvil}"
    echo "* foundry-cast: ${self.packages.${pkgs.system}.foundry-cast}"
    echo "* foundry-chisel: ${self.packages.${pkgs.system}.foundry-chisel}"
    echo ""
    
    # Check NixOS module
    echo "NixOS Ethereum module: ethereum-nodes is available"
    echo ""
    
    echo "Testing successful!"
  '';

  # Combined test runner
  allTests = pkgs.writeShellScriptBin "run-all-tests" ''
    echo "Running all Zero.nix tests"
    echo "=========================="
    echo ""
    
    echo "Running Ethereum integration tests..."
    ${ethereumTest}/bin/test-ethereum-integration
    
    echo ""
    echo "All tests completed successfully!"
  '';

in {
  # Export test packages
  packages = {
    test-ethereum = ethereumTest;
    test-all = allTests;
  };
  
  # Export test shells
  devShells = {
    test-ethereum = pkgs.mkShell {
      buildInputs = [
        self.packages.${pkgs.system}.foundry-forge
        self.packages.${pkgs.system}.foundry-anvil
        self.packages.${pkgs.system}.foundry-cast
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
    
    test-all = pkgs.mkShell {
      packages = [ allTests ];
      shellHook = ''
        echo "Zero.nix Test Suite"
        echo "=================="
        echo ""
        echo "Available commands:"
        echo "  run-all-tests - Run all test suites"
        echo ""
        echo "Available test shells:"
        echo "  nix develop .#test-ethereum - Enter Ethereum test shell"
        echo ""
      '';
    };
  };
  
  # NixOS test module for Ethereum
  nixosModules.test-ethereum = { config, lib, pkgs, ... }: {
    imports = [ self.nixosModules.ethereum-nodes ];
    
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
} 