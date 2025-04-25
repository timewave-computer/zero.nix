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
  };
}
