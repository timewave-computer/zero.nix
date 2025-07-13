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
  };
}
