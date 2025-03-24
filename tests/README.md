# Zero.nix Tests

This directory contains tests for the Zero.nix project.

## Test Structure

Tests are organized as modules within the main flake, rather than as separate flakes. This approach simplifies the structure and makes it easier to run and maintain tests.

Current tests include:
- Ethereum integration test: Tests the Foundry tools and Ethereum node setup

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

1. Add your test implementation to the `run-tests.nix` file in this directory
2. Follow the pattern of existing tests:
   - Create a test script using `pkgs.writeShellScriptBin`
   - Add the test to the `allTests` runner
   - Add corresponding devShell if needed
   - Add any NixOS test modules if applicable

The main flake will automatically expose your new test through its packages and devShells. 