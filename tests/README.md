# Zero.nix Tests

This directory contains tests for Zero.nix components.

## Test Structure

Each test is organized as a separate flake in its own directory.

Current tests:
- [Ethereum Integration Test](./ethereum-integration-test/) - Tests the Ethereum integration components

## Running Tests

You can run all tests with:

```bash
cd tests
nix run
```

Or you can run a specific test:

```bash
cd tests
nix run .#ethereum-test
```

You can also run a test directly from its directory:

```bash
cd tests/ethereum-integration-test
nix run
```

## Development Shells

You can enter development shells for specific tests:

```bash
cd tests
nix develop .#ethereum-test
```

Or directly from the test directory:

```bash
cd tests/ethereum-integration-test
nix develop
```

## Adding New Tests

To add a new test:

1. Create a new directory for your test (e.g., `my-new-test`)
2. Add a `flake.nix` inside the directory
3. Add the test to the inputs in the main `flake.nix`
4. Include the test in the combined test runner 