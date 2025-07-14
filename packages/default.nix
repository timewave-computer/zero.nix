# Purpose: Main packages definition file for zero.nix
{ inputs, ... }:
{
  imports = [
    ./valence-contracts.nix
    ./ethereum.nix
  ];
  
  perSystem = { pkgs, config, lib, system, ... }: 
  let
    # Import Solana tools
    solana-tools = pkgs.callPackage ./solana-tools.nix {
      inherit inputs;
    };
    
    # Solana version constants for shellHook
    sol-version = "2.0.22";
    anchor-version = "0.31.1";
    platform-tools-version = "1.48";
    
    # Common environment variables for development
    commonEnv = {
      SOURCE_DATE_EPOCH = "1686858254"; # Fixed value for reproducible builds
    };
  in {
    packages = {
      # Existing packages
      upload-contract = pkgs.callPackage ./upload-contract {};
      local-ic = pkgs.callPackage ./local-ic.nix {};
      sp1-rust = pkgs.callPackage ./sp1-rust.nix {};
      sp1 = pkgs.callPackage ./sp1.nix {
        inherit (config.packages) sp1-rust;
      };
      
      # Solana packages from solana-tools.nix
      inherit (solana-tools) solana-node anchor setup-solana nightly-rust anchor-wrapper solana-tools;
    };
    
    devShells.default = pkgs.mkShell {
      name = "zero-nix-dev";
      buildInputs = with pkgs; [
        # Basic development tools
        git
        curl
        jq
        
        # Nix tools
        nix-prefetch-git
        
        # Build tools
        pkg-config
        
        # Include our custom packages
        config.packages.upload-contract
        
        # Solana development tools
        config.packages.solana-tools
        
        # Rust toolchain for Solana development
        pkgs.rustc
        pkgs.cargo
        pkgs.rust-analyzer
        
        # Additional tools for Solana development
        nodejs
        yarn
        python3
        protobuf
      ];
      
      shellHook = ''
        echo "Welcome to zero.nix development environment"
        echo "Available packages: upload-contract, local-ic, sp1-rust, sp1"
        echo "Solana tools: solana-node, anchor, setup-solana, nightly-rust"
        echo ""
        echo "Run 'setup-solana' to initialize Solana development environment"
        echo "Solana CLI version: ${sol-version}"
        echo "Anchor CLI version: ${anchor-version}"
        echo "Platform tools version: ${platform-tools-version}"
        echo "Nightly Rust for IDL generation: available"
        echo ""
        
        # Set up platform tools environment to avoid redownloading
        export PLATFORM_TOOLS_DIR=${config.packages.solana-node}/platform-tools
        export SBF_SDK_PATH=${config.packages.solana-node}/platform-tools
        export PATH="${config.packages.solana-node}/platform-tools/rust/bin:${config.packages.solana-node}/bin:$PATH"
        
        # Set Solana environment variables
        export SOURCE_DATE_EPOCH="${commonEnv.SOURCE_DATE_EPOCH}"
        export SOLANA_INSTALL_DIR="$HOME/.cache/solana"
        export RUST_BACKTRACE="1"
        export PROTOC=${pkgs.protobuf}/bin/protoc
        
        # Platform-specific environment variables
        ${lib.optionalString pkgs.stdenv.isDarwin ''
          export MACOSX_DEPLOYMENT_TARGET="11.0"
          export CARGO_BUILD_TARGET="${if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64"}-apple-darwin"
          export RUSTFLAGS="-C link-arg=-undefined -C link-arg=dynamic_lookup"
        ''}
        ${lib.optionalString pkgs.stdenv.isLinux ''
          export CARGO_BUILD_TARGET="${if pkgs.stdenv.isAarch64 then "aarch64" else "x86_64"}-unknown-linux-gnu"
        ''}
        
        # Critical: Set cargo/rustup cache directories to prevent redownloading
        export CARGO_HOME="$HOME/.cache/solana/v${platform-tools-version}/cargo"
        export RUSTUP_HOME="$HOME/.cache/solana/v${platform-tools-version}/rustup"
        
        # Create cache directories
        mkdir -p "$CARGO_HOME" "$RUSTUP_HOME"
        mkdir -p "$SOLANA_INSTALL_DIR/releases" "$SOLANA_INSTALL_DIR/config"
        
        echo "Platform tools configured: $PLATFORM_TOOLS_DIR"
        echo "SBF SDK path: $SBF_SDK_PATH"
      '';
    };
  };
}
