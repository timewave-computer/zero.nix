# Main test module for zero.nix
# Imports and combines all test modules
{ pkgs, self, ... }:

let
  # Import all test modules
  ethereumTests = import ./ethereum/test.nix { inherit pkgs self; };
  
  # Add more test modules here as needed:
  # exampleTests = import ./example/test.nix { inherit pkgs self; };
  
  # All available tests
  allTests = [
    ethereumTests
    # Add more test modules here
    # exampleTests
  ];
  
  # Combined test runner
  testAll = pkgs.writeShellScriptBin "run-all-tests" ''
    echo "Running all Zero.nix tests"
    echo "=========================="
    echo ""
    
    ${builtins.concatStringsSep "\necho \"\"\n" (map (test: test.runnerEntry) allTests)}
    
    echo ""
    echo "All tests completed successfully!"
  '';

in {
  # Export individual test packages
  packages = {
    test-ethereum = ethereumTests.package;
    test-all = testAll;
    
    # Add more test packages here as needed
    # test-example = exampleTests.package;
  };
  
  # Export all devShells
  devShells = {
    test-ethereum = ethereumTests.devShell;
    
    # Add more test shells here as needed
    # test-example = exampleTests.devShell;
    
    # Shell with access to all tests
    test-all = pkgs.mkShell {
      packages = [ testAll ];
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
  
  # Export NixOS test modules
  nixosModules = {
    test-ethereum = ethereumTests.nixosModule;
    
    # Add more test modules here as needed
    # test-example = exampleTests.nixosModule;
  };
} 