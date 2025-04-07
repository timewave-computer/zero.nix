{
  moduleWithSystem,
  ...
}: {
  flake.nixosModules = {
    hermes = moduleWithSystem (
      { inputs', ... }:
      import ./hermes.nix {
        inherit (inputs') cosmos-nix;
      }
    );
    cosmos-nodes = moduleWithSystem (
      {self', inputs', ... }:
      import ./cosmos-node {
        inherit (inputs') cosmos-nix;
        zero-nix = self';
      }
    );
  };
}
