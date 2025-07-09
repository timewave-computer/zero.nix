# Purpose: Solana development tools including CLI, Anchor, and platform tools for SBF compilation
{ pkgs, lib, inputs, ... }:

let
  # Apply rust-overlay to pkgs for rust-bin support
  rustPkgs = pkgs.appendOverlays [
    inputs.rust-overlay.overlays.rust-overlay
  ];
  
  # Solana and Anchor versions - pinned for stability
  sol-version = "2.0.22";
  anchor-version = "0.31.1";
  platform-tools-version = "1.48";
  
  # macOS deployment target (used for all Darwin systems)
  darwinDeploymentTarget = "11.0";
  
  # Common environment variables for Solana development
  commonEnv = {
    SOURCE_DATE_EPOCH = "1686858254"; # Fixed value for reproducible builds
    SOLANA_INSTALL_DIR = "$HOME/.cache/solana";
    ANCHOR_VERSION = anchor-version;
    SOLANA_VERSION = sol-version;
    RUST_BACKTRACE = "1";
  } // lib.optionalAttrs pkgs.stdenv.isDarwin {
    MACOSX_DEPLOYMENT_TARGET = darwinDeploymentTarget;
  };

  # Nightly Rust environment specifically for IDL generation
  nightly-rust = rustPkgs.rust-bin.nightly."2024-12-01".default.override {
    extensions = [ "rust-src" "llvm-tools-preview" ];
  };

  # Unified Solana node derivation including platform tools and CLI tools
  solana-node = pkgs.stdenv.mkDerivation rec {
    pname = "solana-node";
    version = sol-version;

    # Primary Solana CLI source
    solana-src = pkgs.fetchurl {
      url = "https://github.com/anza-xyz/agave/releases/download/v${version}/solana-release-${
        if pkgs.stdenv.isDarwin then
          if pkgs.stdenv.isAarch64 then "aarch64-apple-darwin" else "x86_64-apple-darwin"
        else
          "x86_64-unknown-linux-gnu"
      }.tar.bz2";
      sha256 = if pkgs.stdenv.isDarwin then
        "sha256-upgxwAEvh11+IKVQ1FaZGlx8Z8Ps0CEScsbu4Hv3WH0="  # v2.0.22 macOS ARM64 hash
      else
        "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # TODO: Get correct Linux hash with: nix store prefetch-file --json https://github.com/anza-xyz/agave/releases/download/v2.0.22/solana-release-x86_64-unknown-linux-gnu.tar.bz2
    };

    # Platform tools source
    platform-tools-src = pkgs.fetchurl {
      url = if pkgs.stdenv.isDarwin then
        "https://github.com/anza-xyz/platform-tools/releases/download/v${platform-tools-version}/platform-tools-osx-aarch64.tar.bz2"
      else
        "https://github.com/anza-xyz/platform-tools/releases/download/v${platform-tools-version}/platform-tools-linux-x86_64.tar.bz2";
      sha256 = if pkgs.stdenv.isDarwin then
        "sha256-eZ5M/O444icVXIP7IpT5b5SoQ9QuAcA1n7cSjiIW0t0="  # v1.48 macOS ARM64 hash
      else
        "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";  # TODO: Get correct Linux hash with: nix store prefetch-file --json https://github.com/anza-xyz/platform-tools/releases/download/v1.48/platform-tools-linux-x86_64.tar.bz2
    };

    nativeBuildInputs = with pkgs; [
      makeWrapper
    ] ++ lib.optionals stdenv.isLinux [
      autoPatchelfHook
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.cctools
      darwin.sigtool
    ];

    buildInputs = with pkgs; [
      stdenv.cc.cc.lib
      zlib
      openssl
      libffi
    ] ++ lib.optionals stdenv.isLinux [
      glibc
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    unpackPhase = ''
      runHook preUnpack
      
      # Create separate directories for each source
      mkdir -p solana-cli platform-tools
      
      # Extract Solana CLI
      cd solana-cli
      tar -xf ${solana-src}
      cd ..
      
      # Extract platform tools
      cd platform-tools
      tar -xf ${platform-tools-src}
      cd ..
      
      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall
      
      mkdir -p $out/bin $out/lib $out/platform-tools
      
      # Install Solana CLI tools
      if [ -d "solana-cli/solana-release/bin" ]; then
        cp -r solana-cli/solana-release/bin/* $out/bin/
      elif [ -d "solana-cli/bin" ]; then
        cp -r solana-cli/bin/* $out/bin/
      else
        # Look for any directories with binaries
        for dir in solana-cli/*/; do
          if [ -d "$dir/bin" ]; then
            cp -r "$dir/bin"/* $out/bin/
            break
          fi
        done
      fi
      
      # Install platform tools
      cp -r platform-tools/* $out/platform-tools/
      
      # Make platform tools binaries available in PATH
      if [ -d "$out/platform-tools/rust/bin" ]; then
        for tool in $out/platform-tools/rust/bin/*; do
          if [ -f "$tool" ] && [ -x "$tool" ]; then
            tool_name=$(basename "$tool")
            # Don't override main Solana CLI tools
            if [ ! -f "$out/bin/$tool_name" ]; then
              ln -sf "$tool" "$out/bin/$tool_name"
            fi
          fi
        done
      fi
      
      if [ -d "$out/platform-tools/llvm/bin" ]; then
        for tool in $out/platform-tools/llvm/bin/*; do
          if [ -f "$tool" ] && [ -x "$tool" ]; then
            tool_name=$(basename "$tool")
            # Don't override main Solana CLI tools
            if [ ! -f "$out/bin/$tool_name" ]; then
              ln -sf "$tool" "$out/bin/$tool_name"
            fi
          fi
        done
      fi
      
      # Ensure all binaries are executable
      find $out -type f -executable -exec chmod +x {} \; 2>/dev/null || true
      
      # Fix broken symlinks
      find $out -type l ! -exec test -e {} \; -delete 2>/dev/null || true
      
      # Create wrapper scripts for key tools
      for tool in solana solana-keygen solana-test-validator; do
        if [ -f "$out/bin/$tool" ]; then
          # Backup original binary
          mv "$out/bin/$tool" "$out/bin/.$tool-original"
          
          # Create wrapper script
          cat > "$out/bin/$tool" << EOF
#!/bin/bash
export PLATFORM_TOOLS_DIR="$out/platform-tools"
export SBF_SDK_PATH="$out/platform-tools"
export PATH="$out/platform-tools/rust/bin:$out/platform-tools/llvm/bin:\$PATH"
exec "$out/bin/.$tool-original" "\$@"
EOF
          chmod +x "$out/bin/$tool"
        fi
      done
      
      # Create special wrapper for cargo-build-sbf that bypasses platform tools installation
      if [ -f "$out/bin/cargo-build-sbf" ]; then
        # Backup original binary
        mv "$out/bin/cargo-build-sbf" "$out/bin/.cargo-build-sbf-original"
        
        # Create wrapper script that uses cargo directly with SBF target
        cat > "$out/bin/cargo-build-sbf" << EOF
#!/bin/bash
export PLATFORM_TOOLS_DIR="$out/platform-tools"
export SBF_SDK_PATH="$out/platform-tools"
export PATH="$out/platform-tools/rust/bin:$out/platform-tools/llvm/bin:\$PATH"

# Handle both standalone cargo-build-sbf and cargo build-sbf subcommand usage
if [[ "\$1" == "build-sbf" ]]; then
  # Called as cargo subcommand: cargo build-sbf [args]
  # Remove the "build-sbf" argument and pass the rest
  shift
fi

# Use cargo directly with SBF target instead of cargo-build-sbf to avoid installation issues
# This bypasses the platform tools installation logic entirely
exec cargo build --release --target sbf-solana-solana "\$@"
EOF
        chmod +x "$out/bin/cargo-build-sbf"
      fi
      
      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Complete Solana node with platform tools and CLI";
      homepage = "https://solana.com";
      license = licenses.asl20;
      platforms = [ "x86_64-linux" "x86_64-darwin" "aarch64-darwin" ];
      maintainers = [ ];
    };
  };

  # Build anchor CLI from source with rust-overlay
  anchor = pkgs.rustPlatform.buildRustPackage rec {
    pname = "anchor-cli";
    version = anchor-version;

    src = pkgs.fetchFromGitHub {
      owner = "coral-xyz";
      repo = "anchor";
      rev = "v${version}";
      hash = "sha256-pvD0v4y7DilqCrhT8iQnAj5kBxGQVqNvObJUBzFLqzA=";
      fetchSubmodules = true;
    };

    useFetchCargoVendor = true;
    cargoHash = "sha256-fjhLA+utQdgR75wg+/N4VwASW6+YBHglRPj14sPHmGA=";

    # Build the CLI package specifically
    cargoBuildFlags = [ "--package" "anchor-cli" ];
    cargoTestFlags = [ "--package" "anchor-cli" ];
    
    # Skip tests for faster builds
    doCheck = false;

    nativeBuildInputs = with pkgs; [
      pkg-config
      rustc
      cargo
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
    ];

    buildInputs = with pkgs; [
      openssl
      libiconv
    ] ++ lib.optionals stdenv.isLinux [
      libudev-zero
    ] ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
    ];

    # Environment variables for building
    OPENSSL_NO_VENDOR = "1";
    SOURCE_DATE_EPOCH = commonEnv.SOURCE_DATE_EPOCH;

    # Platform-specific environment variables
    MACOSX_DEPLOYMENT_TARGET = lib.optionalString pkgs.stdenv.isDarwin darwinDeploymentTarget;
    RUSTFLAGS = lib.optionalString pkgs.stdenv.isDarwin 
      "-C link-arg=-undefined -C link-arg=dynamic_lookup";

    # Clean build without toolchain installation patches
    postPatch = ''
      # Remove any toolchain installation code that might interfere
      find . -name "*.rs" -type f -exec sed -i 's/install_toolchain_if_needed.*;//g' {} \;
    '';

    meta = with pkgs.lib; {
      description = "Solana Sealevel Framework CLI";
      homepage = "https://github.com/coral-xyz/anchor";
      license = licenses.asl20;
      maintainers = [ ];
      platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    };
  };

  # Setup script for Solana environment
  setup-solana = pkgs.writeShellScriptBin "setup-solana" ''
    set -e
    
    echo "Setting up Solana development environment..."
    echo "Platform tools v${platform-tools-version} location: ${solana-node}"
    echo "Solana CLI v${sol-version} location: ${solana-node}"
    echo "Anchor CLI v${anchor-version} location: ${anchor}"
    
    # Create cache directories with proper permissions
    SOLANA_CACHE_DIR="$HOME/.cache/solana"
    mkdir -p "$SOLANA_CACHE_DIR/v${platform-tools-version}/cargo" "$SOLANA_CACHE_DIR/v${platform-tools-version}/rustup"
    mkdir -p "$SOLANA_CACHE_DIR/releases" "$SOLANA_CACHE_DIR/config"
    chmod -R 755 "$SOLANA_CACHE_DIR"
    
    echo "Solana development environment setup complete!"
  '';

  # Wrapper for anchor that uses platform tools and nightly rust for IDL generation
  anchor-wrapper = pkgs.writeShellScriptBin "anchor" ''
    set -e
    
    # Set up platform tools environment for SBF compilation  
    export PLATFORM_TOOLS_DIR=${solana-node}/platform-tools
    export SBF_SDK_PATH=${solana-node}/platform-tools
    
    # IMPORTANT: Put cargo-shim first in PATH to intercept +nightly calls
    export PATH="${cargo-shim}/bin:${solana-node}/platform-tools/rust/bin:${solana-node}/bin:$PATH"
    
    # Set required environment variables
    export SOURCE_DATE_EPOCH="${commonEnv.SOURCE_DATE_EPOCH}" 
    export RUST_BACKTRACE=1
    export PROTOC=${pkgs.protobuf}/bin/protoc
    
    # Platform-specific environment variables
    ${lib.optionalString pkgs.stdenv.isDarwin ''
      export MACOSX_DEPLOYMENT_TARGET="${darwinDeploymentTarget}"
      export CARGO_BUILD_TARGET="${if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64"}-apple-darwin"
      export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
    ''}
    ${lib.optionalString pkgs.stdenv.isLinux ''
      export CARGO_BUILD_TARGET="${if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64"}-unknown-linux-gnu"
    ''}
    
    # Critical: Set cargo/rustup cache directories to prevent redownloading
    export CARGO_HOME="$HOME/.cache/solana/v${platform-tools-version}/cargo"
    export RUSTUP_HOME="$HOME/.cache/solana/v${platform-tools-version}/rustup"
    
    # Ensure cache directories exist
    mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"
    
    # Check if this is for IDL generation and use nightly rust
    if [[ "$*" == *"idl"* ]]; then
      export PATH="${nightly-rust}/bin:${cargo-shim}/bin:${solana-node}/bin:$PATH"
      export RUSTC="${nightly-rust}/bin/rustc"
      export CARGO="${cargo-shim}/bin/cargo"
    fi
    
    # Run anchor with platform tools environment
    exec "${anchor}/bin/anchor" "$@"
  '';

  # Create a cargo shim that intercepts +nightly calls
  cargo-shim = pkgs.writeShellScriptBin "cargo" ''
    set -e
    
    # Check if the first argument is +nightly
    if [[ "$1" == "+nightly" ]]; then
      # Shift off the +nightly argument
      shift
      # Use the nightly rust cargo
      exec "${nightly-rust}/bin/cargo" "$@"
    else
      # Use the default cargo
      exec "${solana-node}/platform-tools/rust/bin/cargo" "$@"
    fi
  '';

in {
  # Individual packages
  inherit solana-node anchor setup-solana nightly-rust;
  anchor-wrapper = anchor-wrapper;
  cargo-shim = cargo-shim;
  
  # Combined solana development environment
  solana-tools = pkgs.symlinkJoin {
    name = "solana-tools";
    paths = [
      solana-node
      anchor-wrapper
      cargo-shim
      setup-solana
    ];
  };
} 