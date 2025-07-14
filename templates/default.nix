let
  commonWelcome = ''
    ## More info
     - Zero.nix Docs: https://timewave.computer/zero.nix
  '';
in
{
  flake.templates = {
    zk-dev = {
      path = ./zk-development;
      description = "Simple ZK development environment";
      welcomeText = ''
        # Simple ZK development environment
        ## Provided packages
         - sp1 (cargo prove)
         - rust-sp1

        ${commonWelcome}
      '';
    };
    
    solana-dev = {
      path = ./solana-development;
      description = "Solana development environment";
      welcomeText = ''
        # Solana development environment
        ## Provided packages
         - solana CLI (v2.0.22)
         - anchor CLI (v0.31.1)
         - platform tools (v1.48)
         - cargo-build-sbf
         - Rust toolchain

        ## Getting started
         - Run 'nix develop' to enter the development environment
         - Run 'setup-solana' to initialize Solana tools
         - Create a new Anchor project with 'anchor init my-project'
         - Build SBF programs with 'cargo-build-sbf'

        ${commonWelcome}
      '';
    };
    
    ethereum-node = {
      path = ./ethereum-node;
      description = "Ethereum node deployment with geth and lighthouse";
      welcomeText = ''
        # Ethereum node deployment
        ## Provided services
         - geth: Ethereum execution client
         - lighthouse: Ethereum consensus client

        ## Usage
         - Deploy: `nixos-rebuild switch --flake .#ethereum-node`
         - Monitor: `systemctl status ethereum-execution-mainnet ethereum-consensus-mainnet`

        ${commonWelcome}
      '';
    };
    
    ethereum-development = {
      path = ./ethereum-development;
      description = "Ethereum development environment with geth and lighthouse";
      welcomeText = ''
        # Ethereum development environment
        ## Provided tools
         - geth: Ethereum execution client
         - lighthouse: Ethereum consensus client
         - curl, jq, openssl: Development utilities

        ## Usage
         - Enter shell: `nix develop`
         - Start testnet: `geth --sepolia --datadir ./data/geth --http --ws`
         - Start consensus: `lighthouse bn --network sepolia --datadir ./data/lighthouse`

        ${commonWelcome}
      '';
    };
  };
}
