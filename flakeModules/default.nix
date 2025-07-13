{ self, inputs, ... }:
let
  default-inputs = {
    zero-nix = self;
    cosmos-nix = inputs.cosmos-nix;
  };
in
{
  flake.flakeModules = {
    upload-contracts = {
      imports = [ ./upload-contracts/default.nix ];
      perSystem.upload-contracts = { inherit default-inputs; };
    };
    valence-contracts = {
      imports = [ ./valence-contracts.nix ];
      perSystem.valence-contracts = { inherit default-inputs; };
    };
    ethereum-development = {
      imports = [ ./ethereum-development/default.nix ];
      perSystem.ethereum-development = { inherit default-inputs; };
    };
  };
}
