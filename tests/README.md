# Zero.nix Tests

This directory contains tests for the Zero.nix project.

## File Structure

The test system is organized with clear file naming to avoid confusion:

- `all-tests.nix` - Main coordinator that imports and combines all individual tests
- Each test type has its own directory with a descriptive `test.nix` file

Current test directories:
- `ethereum/` - Tests for the Ethereum integration components
  - `ethereum/test.nix` - The Ethereum test implementation

## Running Tests

You can run all tests at once:

```bash
nix run .#test-all
```

Or run a specific test:

```bash
nix run .#test-ethereum
```

## Development Shells

To enter a development shell for working with specific test environments:

```bash
# Enter the Ethereum test shell
nix develop .#test-ethereum

# Enter the test runner shell with all tests
nix develop .#test-all
```

## Adding New Tests

To add a new test:

1. Create a new directory for your test type (e.g., `tests/cosmos/`)
2. Create a `test.nix` in your test directory following this pattern:
   ```nix
   { pkgs, self, ... }:
   
   let
     testScript = pkgs.writeShellScriptBin "test-your-test-name" ''
       # Your test script here
     '';
   
   in {
     package = testScript;
     
     runnerEntry = ''
       echo "Running your test..."
       ${testScript}/bin/test-your-test-name
     '';
     
     devShell = pkgs.mkShell {
       # Your test shell environment
     };
     
     nixosModule = { config, lib, pkgs, ... }: {
       # Optional NixOS test module
     };
   }
   ```

3. Add your test module to `tests/all-tests.nix`:
   - Import your test module: `yourTests = import ./your-test/test.nix { inherit pkgs self; };`
   - Add it to the `allTests` list
   - Add it to the exports sections (packages, devShells, nixosModules)

The main flake will automatically expose your new test through its packages and devShells. 