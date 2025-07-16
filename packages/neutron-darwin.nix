{ lib
, stdenv
, fetchFromGitHub
, buildGoModule
, rustPlatform
, fetchurl
, darwin
, libiconv
, writeShellScriptBin
, makeWrapper
}:

let
  # Build libwasmvm for Darwin following the quartz approach
  libwasmvm = rustPlatform.buildRustPackage rec {
    pname = "libwasmvm";
    version = "2.1.5";

    src = fetchFromGitHub {
      owner = "CosmWasm";
      repo = "wasmvm";
      rev = "v${version}";
      hash = "sha256-gdFxL/9K3uE3Ymu3OUYWnT7qibGWjXMvNkVHUQgQqL0=";
    };

    sourceRoot = "${src.name}/libwasmvm";
    
    cargoHash = "sha256-8Sge63vFK3fOMZXqA7hxnJV5r0VvJvqhUlgKDiEMKLQ=";

    nativeBuildInputs = lib.optionals stdenv.isDarwin [
      darwin.cctools
    ];

    buildInputs = lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
      libiconv
    ];

    # Set macOS deployment target for compatibility
    preBuild = lib.optionalString stdenv.isDarwin ''
      export MACOSX_DEPLOYMENT_TARGET="11.0"
    '';

    postInstall = ''
      cp target/${stdenv.hostPlatform.config}/release/libwasmvm.${if stdenv.isDarwin then "dylib" else "so"} $out/lib/
    '';

    doCheck = false;

    meta = {
      description = "WebAssembly VM for Cosmos chains";
      homepage = "https://github.com/CosmWasm/wasmvm";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  };

  # Build neutrond with Darwin support
  neutrond = buildGoModule rec {
    pname = "neutrond";
    version = "6.0.3";

    src = fetchFromGitHub {
      owner = "neutron-org";
      repo = "neutron";
      rev = "v${version}";
      hash = "sha256-4vgJMdJFXvAJKE7zJEcJCeYZ+YT5OdNlT3HzfuGOiN8=";
    };

    vendorHash = "sha256-VnJKGYjU6eZVAQPG9OJ7Kxb7oWJkLXzS8xGvVnFj0jg=";

    # Apply patch to remove admin module message filtering
    patches = [
      ./neutron-skip-ccv-msg-filter.patch
    ];

    # Enable CGO for libwasmvm
    CGO_ENABLED = "1";

    # Set build tags
    tags = [ "netgo" "skip_ccv_msg_filter" ];

    # Darwin-specific build inputs
    nativeBuildInputs = [ makeWrapper ] ++ lib.optionals stdenv.isDarwin [
      darwin.cctools
    ];

    buildInputs = [ libwasmvm ] ++ lib.optionals stdenv.isDarwin [
      darwin.apple_sdk.frameworks.Security
      darwin.apple_sdk.frameworks.SystemConfiguration
      darwin.apple_sdk.frameworks.CoreFoundation
      darwin.apple_sdk.frameworks.CoreServices
      libiconv
    ];

    # Set environment variables for build
    preBuild = ''
      export CGO_CFLAGS="-I${libwasmvm}/include"
      export CGO_LDFLAGS="-L${libwasmvm}/lib -lwasmvm"
      ${lib.optionalString stdenv.isDarwin ''
        export MACOSX_DEPLOYMENT_TARGET="11.0"
      ''}
    '';

    # Fix dynamic library paths on Darwin
    postInstall = lib.optionalString stdenv.isDarwin ''
      install_name_tool -add_rpath ${libwasmvm}/lib $out/bin/neutrond
      install_name_tool -change @rpath/libwasmvm.dylib ${libwasmvm}/lib/libwasmvm.dylib $out/bin/neutrond
    '';

    # Create wrapper with proper library paths
    postFixup = ''
      wrapProgram $out/bin/neutrond \
        --prefix ${if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"} : "${libwasmvm}/lib"
    '';

    doCheck = false;

    meta = {
      description = "The most secure permissionless smart contract platform";
      homepage = "https://neutron.org";
      license = lib.licenses.asl20;
      platforms = lib.platforms.unix;
    };
  };

  # Create a smart wrapper following the quartz pattern
  neutronWrapper = writeShellScriptBin "neutron" ''
    #!/usr/bin/env bash
    
    # Function to check if a command exists
    command_exists() {
      command -v "$1" >/dev/null 2>&1
    }
    
    # First, try the Nix-built neutrond
    if [ -x "${neutrond}/bin/neutrond" ]; then
      export ${if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"}="${libwasmvm}/lib:$${if stdenv.isDarwin then "DYLD_LIBRARY_PATH" else "LD_LIBRARY_PATH"}"
      exec "${neutrond}/bin/neutrond" "$@"
    # Fall back to system neutrond if available
    elif command_exists neutrond; then
      echo "Warning: Using system neutrond. Some features may not work as expected." >&2
      exec neutrond "$@"
    else
      echo "Error: neutrond not found. Please install neutron or ensure it's in your PATH." >&2
      echo "You can install it via this flake or visit https://docs.neutron.org for installation instructions." >&2
      exit 1
    fi
  '';

in
{
  inherit libwasmvm neutrond neutronWrapper;
  
  # Export the main wrapper as the default
  neutron = neutronWrapper;
}