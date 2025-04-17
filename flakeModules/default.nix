{ self, inputs, ... }:
{
  flake.flakeModules = {
    upload-contracts = import ./upload-contracts {
      zero-nix = self;
      inherit (inputs) cosmos-nix;
    };
    valence-contracts = import ./valence-contracts.nix {
      zero-nix = self;
    };
  };
}
