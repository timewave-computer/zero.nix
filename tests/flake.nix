{
  description = "Zero.nix Tests";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    zero-nix.url = "..";
    ethereum-test.url = "./ethereum-integration-test";
  };

  outputs = { self, nixpkgs, zero-nix, ethereum-test, ... }:
    let
      systems = [ "aarch64-darwin" "aarch64-linux" "x86_64-darwin" "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system: {
        # Export all individual test packages
        ethereum-test = ethereum-test.packages.${system}.default;
        
        # Create a combined test runner
        default = 
          let 
            pkgs = nixpkgs.legacyPackages.${system};
          in
          pkgs.writeShellScriptBin "run-all-tests" ''
            echo "Running all Zero.nix tests"
            echo "=========================="
            echo ""
            
            echo "Running Ethereum integration tests..."
            ${ethereum-test.packages.${system}.default}/bin/test-ethereum-integration
            
            echo ""
            echo "All tests completed successfully!"
          '';
      });
      
      # Export all individual devShells
      devShells = forAllSystems (system: {
        ethereum-test = ethereum-test.devShells.${system}.default;
        default = nixpkgs.legacyPackages.${system}.mkShell {
          packages = [
            self.packages.${system}.default
          ];
          shellHook = ''
            echo "Zero.nix Test Suite"
            echo "=================="
            echo ""
            echo "Available commands:"
            echo "  run-all-tests - Run all test suites"
            echo ""
            echo "Available test shells:"
            echo "  nix develop .#ethereum-test - Enter Ethereum test shell"
            echo ""
          '';
        };
      });
    };
} 