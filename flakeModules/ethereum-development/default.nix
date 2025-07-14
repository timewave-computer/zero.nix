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
          devshells.ethereum = {
            name = "ethereum-development";
            
            commands = [
              {
                package = self'.packages.geth;
                help = "Ethereum execution client";
              }
              {
                package = self'.packages.lighthouse;
                help = "Ethereum consensus client";
              }
              {
                package = pkgs.curl;
                help = "HTTP client for API testing";
              }
              {
                package = pkgs.jq;
                help = "JSON processor for API responses";
              }
              {
                package = pkgs.openssl;
                help = "SSL/TLS toolkit";
              }
            ];
            
            motd = ''
              {14}{bold}Ethereum development environment{reset}
              {9}Network: ${cfg.network}{reset}
              
              {13}Quick start:{reset}
                geth ${if cfg.network == "mainnet" then "" else "--${cfg.network}"} --datadir ./data/geth --http --ws
                lighthouse bn --network ${if cfg.network == "mainnet" then "mainnet" else cfg.network} --datadir ./data/lighthouse
            '';
          };
        };
      }
    );
  };
} 