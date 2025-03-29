{ self, inputs, ... }:
{
  flake.flakeModules = {
    upload-contracts = import ./upload-contracts {
      zero-nix = self;
      inherit (inputs) cosmos-nix;
    };
    upload-valence-contracts = ./upload-valence-contracts.nix;
  };
}
