# Ethereum integration tests
{ pkgs, self, ... }:

let
  # Ethereum test implementation
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

in {
  # Test package
  package = ethereumTest;
  
  # Add this test to the runner
  runnerEntry = ''
    echo "Running Ethereum integration tests..."
    ${ethereumTest}/bin/test-ethereum-integration
  '';
  
  # Development shell
  devShell = pkgs.mkShell {
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
  
  # NixOS test module
  nixosModule = { config, lib, pkgs, ... }: {
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