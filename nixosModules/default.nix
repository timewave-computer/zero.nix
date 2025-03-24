{
  inputs',
  ...
}: {
  flake.nixosModules = {
    hermes = import ./hermes.nix {
      inherit (inputs') cosmos-nix;
    };
    cosmos-nodes = import ./cosmos-node;
    ethereum-nodes = import ./ethereum-node;
  };
}
