{ lib, self, inputs, ... }:
let
  valence-contracts-srcs = lib.filterAttrs (name: _:
    lib.hasPrefix "valence-contracts" name
  ) inputs;
  getVersion = lib.removePrefix "valence-contracts-";
in

{
  perSystem = {
    valence-contracts.default-inputs = {
      zero-nix = self;
      cosmos-nix = inputs.cosmos-nix;
    };
    valence-contracts.builds =
      lib.mapAttrs
        (name: input: {
          src = input;
          version = getVersion name;
        })
        valence-contracts-srcs;
  };
}
