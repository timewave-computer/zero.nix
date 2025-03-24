{ pkgs, lib, ... }:

let
  installFoundry = pkgs.writeShellScriptBin "install-foundry" ''
    if ! command -v foundryup &> /dev/null; then
      echo "Installing foundryup..."
      ${pkgs.curl}/bin/curl -L https://foundry.paradigm.xyz | bash
    fi
    
    # Source the environment to get foundryup in path
    source "$HOME/.foundry/bin/foundryup" 2>/dev/null || true
    
    # Run foundryup to install the latest stable version of Foundry
    export PATH="$PATH:$HOME/.foundry/bin"
    foundryup
  '';

  # A wrapper for forge
  forge = pkgs.writeShellScriptBin "forge" ''
    if ! command -v forge &> /dev/null; then
      echo "Foundry not found. Installing..."
      ${installFoundry}/bin/install-foundry
    fi
    
    # Execute forge with all arguments passed
    exec "$HOME/.foundry/bin/forge" "$@"
  '';

  # A wrapper for anvil
  anvil = pkgs.writeShellScriptBin "anvil" ''
    if ! command -v anvil &> /dev/null; then
      echo "Foundry not found. Installing..."
      ${installFoundry}/bin/install-foundry
    fi
    
    # Execute anvil with all arguments passed
    exec "$HOME/.foundry/bin/anvil" "$@"
  '';

  # A wrapper for cast
  cast = pkgs.writeShellScriptBin "cast" ''
    if ! command -v cast &> /dev/null; then
      echo "Foundry not found. Installing..."
      ${installFoundry}/bin/install-foundry
    fi
    
    # Execute cast with all arguments passed
    exec "$HOME/.foundry/bin/cast" "$@"
  '';

  # A wrapper for chisel
  chisel = pkgs.writeShellScriptBin "chisel" ''
    if ! command -v chisel &> /dev/null; then
      echo "Foundry not found. Installing..."
      ${installFoundry}/bin/install-foundry
    fi
    
    # Execute chisel with all arguments passed
    exec "$HOME/.foundry/bin/chisel" "$@"
  '';

in {
  foundry-installer = installFoundry;
  foundry-forge = forge;
  foundry-anvil = anvil;
  foundry-cast = cast;
  foundry-chisel = chisel;
} 