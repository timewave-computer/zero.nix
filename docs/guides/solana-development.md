# Solana Development Guide

This guide covers how to use zero.nix for Solana development, including setup of the Solana CLI, Anchor framework, and platform tools.

## Overview

Zero.nix provides a complete Solana development environment with:
- **Solana CLI** (v2.0.22) - Core Solana command-line tools
- **Anchor CLI** (v0.31.1) - Solana development framework
- **Platform Tools** (v1.48) - Rust compiler and LLVM tools optimized for Solana
- **SBF compilation** - Support for Solana Berkeley Format programs

## Quick Start

### Using the Template

Create a new Solana project using the zero.nix template:

```bash
nix flake new -t github:timewave-computer/zero.nix#solana-dev my-solana-project
cd my-solana-project
nix develop
```

### Manual Setup

Add zero.nix to your existing Solana project:

```nix
{
  description = "My Solana project";

  inputs = {
    zero-nix.url = "github:timewave-computer/zero.nix";
  };

  outputs = { self, zero-nix }: 
    zero-nix.lib.mkFlake {
      inherit self;
      src = ./.;
    };
}
```

## Development Environment

### Entering the Development Environment

```bash
nix develop
```

This provides access to:
- `solana` - Solana CLI tools
- `anchor` - Anchor framework CLI
- `cargo-build-sbf` - SBF program compilation
- `setup-solana` - Environment initialization script

### Environment Setup

Initialize the Solana development environment:

```bash
setup-solana
```

This script:
- Creates necessary cache directories
- Verifies platform tools installation
- Sets up proper permissions

## Working with Anchor

### Creating a New Anchor Project

```bash
anchor init my-project
cd my-project
```

### Building Anchor Programs

```bash
# Build the program
anchor build

# Build with SBF compilation
cargo-build-sbf
```

### Testing Anchor Programs

```bash
# Run tests
anchor test

# Run tests with local validator
anchor test --skip-local-validator
```

## Solana CLI Usage

### Configuration

```bash
# Configure Solana CLI for devnet
solana config set --url https://api.devnet.solana.com

# Generate a new keypair
solana-keygen new

# Check balance
solana balance
```

### Local Development

```bash
# Start local test validator
solana-test-validator

# Deploy to local cluster
solana program deploy target/deploy/my_program.so
```

## Platform Tools

The zero.nix Solana environment includes platform tools that provide:
- **Rust toolchain** - Optimized for Solana development
- **LLVM tools** - Required for SBF compilation
- **Cargo extensions** - SBF-specific build tools

### Platform Tools Environment

Platform tools are automatically configured with:
- `PLATFORM_TOOLS_DIR` - Points to platform tools directory
- `SBF_SDK_PATH` - SDK path for SBF compilation
- `PATH` - Extended to include platform tools

## SBF Program Development

### Building SBF Programs

```bash
# Build SBF programs directly
cargo-build-sbf --manifest-path=Cargo.toml

# Build with Anchor (recommended)
anchor build
```

### SBF Compilation Environment

The environment automatically configures:
- Rust toolchain compatible with Solana
- LLVM tools for SBF target compilation
- Proper linker settings for macOS

## Available Tools

### Core Tools

- **solana** - Main Solana CLI
- **solana-keygen** - Key generation and management
- **solana-test-validator** - Local test validator
- **anchor** - Anchor framework CLI
- **cargo-build-sbf** - SBF program compilation

### Development Tools

- **rustc** - Rust compiler
- **cargo** - Rust package manager
- **rust-analyzer** - Rust language server
- **nodejs** - JavaScript runtime
- **python3** - Python interpreter

## Configuration

### Environment Variables

The development environment automatically sets:

```bash
MACOSX_DEPLOYMENT_TARGET=11.0           # macOS deployment target
SOLANA_INSTALL_DIR=$HOME/.cache/solana  # Solana cache directory
ANCHOR_VERSION=0.31.1                   # Anchor version
SOLANA_VERSION=2.0.22                   # Solana version
RUST_BACKTRACE=1                        # Enable Rust backtraces
PLATFORM_TOOLS_DIR=<nix-store-path>     # Platform tools directory (avoids redownloading)
SBF_SDK_PATH=<nix-store-path>           # SBF SDK path for compilation
PROTOC=<nix-store-path>/bin/protoc      # Protocol buffers compiler
CARGO_HOME=$HOME/.cache/solana/v1.48/cargo     # Cargo cache directory (prevents redownloading)
RUSTUP_HOME=$HOME/.cache/solana/v1.48/rustup   # Rustup cache directory (prevents redownloading)
```

These environment variables ensure that:
- Platform tools are not redownloaded on each build
- SBF compilation uses the pre-installed tools
- Proper macOS deployment target is set
- Debugging information is available
- Cargo and rustup use cached platform tools configuration

### Custom Configuration

Override environment variables in your `flake.nix`:

```nix
{
  outputs = { self, zero-nix }: 
    zero-nix.lib.mkFlake {
      inherit self;
      src = ./.;
      
      devShells.default = zero-nix.devShells.default.override {
        shellHook = ''
          # Custom solana configuration
          solana config set --url https://api.mainnet-beta.solana.com
          
          # Project-specific setup
          echo "My Solana project initialized"
        '';
      };
    };
}
```

## Troubleshooting

### Common Issues

1. **Platform tools not found**
   - Run `setup-solana` to initialize environment
   - Verify `PLATFORM_TOOLS_DIR` is set correctly

2. **SBF compilation fails**
   - Ensure `cargo-build-sbf` is available in PATH
   - Check that `SBF_SDK_PATH` points to platform tools

3. **Anchor build errors**
   - Verify Anchor.toml configuration
   - Check that all dependencies are available

### Debug Mode

Enable verbose output for debugging:

```bash
RUST_BACKTRACE=full anchor build
```

## Integration with Existing Projects

### Adding to Existing Rust Projects

Add zero.nix to your `flake.nix`:

```nix
{
  inputs = {
    zero-nix.url = "github:timewave-computer/zero.nix";
  };

  outputs = { self, zero-nix }: {
    devShells.default = zero-nix.devShells.default.override {
      buildInputs = with zero-nix.legacyPackages.${system}; [
        solana-tools
        # Add your existing tools here
      ];
    };
  };
}
```

### Multi-Chain Development

Combine with other zero.nix modules:

```nix
{
  outputs = { self, zero-nix }: 
    zero-nix.lib.mkFlake {
      inherit self;
      src = ./.;
      
      # Enable multiple development environments
      devShells = {
        # Solana development
        solana = zero-nix.devShells.default.override {
          buildInputs = [ zero-nix.packages.solana-tools ];
        };
        
        # Cosmos development  
        cosmos = zero-nix.devShells.default.override {
          buildInputs = [ zero-nix.packages.cosmos-tools ];
        };
      };
    };
}
```

## Next Steps

- Explore the [Anchor documentation](https://book.anchor-lang.com/)
- Learn about [Solana program development](https://docs.solana.com/developing/programming-model/overview)
- Check out [Solana CLI reference](https://docs.solana.com/cli)
- Join the [Solana Discord](https://discord.gg/solana)

## Contributing

To contribute improvements to the Solana development environment:

1. Fork the [zero.nix repository](https://github.com/timewave-computer/zero.nix)
2. Make your changes to `packages/default.nix`
3. Test with `nix develop`
4. Submit a pull request

## Version Information

- **Solana CLI**: v2.0.22
- **Anchor CLI**: v0.31.1
- **Platform Tools**: v1.48
- **Rust**: Compatible with Solana (via platform tools) 