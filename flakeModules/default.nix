{ self, inputs, ... }:
{
  flake.flakeModules = {
    upload-contracts = import ./upload-contracts {
      zero-nix = self;
    };
    valence-contracts = import ./valence-contracts/default.nix {
      inherit (inputs) crane rust-overlay;
    };
  };
}
