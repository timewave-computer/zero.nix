{ moduleWithSystem, ... }:
{
  flake.flakeModules = {
    upload-contracts = moduleWithSystem (
      { self', inputs', ... }:
      import ./upload-contracts {
        zero-nix = self';
        inherit (inputs') cosmos-nix;
      }
    );
    upload-valence-contracts = ./upload-valence-contracts.nix;
  };
}
