# Ethereum development flake module for zero.nix
# Provides development environment with ethereum tools
{
  lib,
  flake-parts-lib,
  ...
}: let
  inherit (flake-parts-lib) mkPerSystemOption;
  inherit (lib) types;
in {
  _file = ./default.nix;
  options = {
    perSystem = mkPerSystemOption (
      {
        config,
        pkgs,
        self',
        system,
        ...
      }: let
        cfg = config.ethereum-development;
      in {
        options = {
          ethereum-development.enable = lib.mkEnableOption "ethereum development environment";
          
          ethereum-development.network = lib.mkOption {
            type = lib.types.enum [ "mainnet" "goerli" "sepolia" "holesky" ];
            default = "sepolia";
            description = "Default ethereum network for development";
          };
        };
        
        config = lib.mkIf cfg.enable {
          devShells.ethereum = pkgs.mkShell {
            name = "ethereum-development";
            
            packages = with pkgs; [
              # Basic ethereum tools
              self'.packages.geth
              self'.packages.lighthouse
              
              # Development tools
              curl
              jq
              openssl
            ];
            
            shellHook = ''
              echo "Ethereum development environment"
              echo "Network: ${cfg.network}"
              echo ""
              echo "Available tools:"
              echo "  - geth: Ethereum execution client"
              echo "  - lighthouse: Ethereum consensus client"
              echo ""
              echo "Quick start:"
              echo "  geth ${if cfg.network == "mainnet" then "" else "--${cfg.network}"} --datadir ./data/geth --http --ws"
              echo "  lighthouse bn --network ${if cfg.network == "mainnet" then "mainnet" else cfg.network} --datadir ./data/lighthouse"
              echo ""
            '';
          };
        };
      }
    );
  };
} 