# Ethereum packages module for zero.nix
# Provides geth and lighthouse packages
{
  perSystem = { system, pkgs, ... }: {
    packages = {
      # Geth - Ethereum execution client
      geth = pkgs.buildGoModule rec {
        pname = "geth";
        version = "1.15.6";
        
        src = pkgs.fetchFromGitHub {
          owner = "ethereum";
          repo = "go-ethereum";
          rev = "v${version}";
          hash = "sha256-BdNv0rx+9/F0leNj2AAej8psy8X8HysDrIXheVOOkSo=";
        };
        
        vendorHash = "sha256-KRVI1DxjoABZFJkmjGaMVlmxIHvtSFuvmpuMuvr8Pws=";
        
        doCheck = false;
        
        subPackages = [ "cmd/geth" ];
        
        # Build configuration
        env.CGO_ENABLED = if pkgs.stdenv.isLinux then "1" else "0";
        buildFlags = [ "-mod=readonly" ];
        
        # Add necessary inputs for CGO on Linux
        buildInputs = with pkgs; lib.optionals stdenv.isLinux [
          glibc
          gcc
        ];
        
        nativeBuildInputs = with pkgs; lib.optionals stdenv.isLinux [
          pkg-config
        ];
        
        meta = with pkgs.lib; {
          description = "Official Go implementation of the Ethereum protocol";
          homepage = "https://github.com/ethereum/go-ethereum";
          license = licenses.lgpl3Plus;
          mainProgram = "geth";
        };
      };
      
      # Lighthouse - Ethereum consensus client
      lighthouse = pkgs.rustPlatform.buildRustPackage rec {
        pname = "lighthouse";
        version = "5.3.0";
        
        src = pkgs.fetchFromGitHub {
          owner = "sigp";
          repo = "lighthouse";
          rev = "v${version}";
          hash = "sha256-wIj+YabyUrgLjWCfjCAH/Xb8jUG6ss+5SwnE2M82a+4=";
        };
        
        cargoHash = "sha256-v/gOTbkzcwmqV8XCzkLzAl6LyshVBWxUclZxx1mr53o=";
        useFetchCargoVendor = true;
        
        buildInputs = with pkgs; [
          openssl
        ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin [
          pkgs.darwin.apple_sdk.frameworks.Security
          pkgs.darwin.apple_sdk.frameworks.SystemConfiguration
        ];
        
        nativeBuildInputs = with pkgs; [
          pkg-config
          protobuf
          cmake
        ];
        
        # Disable tests that require network access
        doCheck = false;
        
        # Build only the lighthouse binary
        cargoBuildFlags = [ "--bin" "lighthouse" ];
        
        meta = with pkgs.lib; {
          description = "Ethereum consensus client written in Rust";
          homepage = "https://github.com/sigp/lighthouse";
          license = licenses.asl20;
          mainProgram = "lighthouse";
        };
      };
    };
  };
} 