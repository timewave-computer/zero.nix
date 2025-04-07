{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules = {
    cosmos-nodes = import ./cosmos-node;
    hermes = moduleWithSystem (
      { inputs', ... }:
      import ./hermes.nix {
        inherit (inputs') cosmos-nix;
      }
    );
  };
}
