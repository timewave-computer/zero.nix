{ lib, inputs, ... }:
let
  valence-contracts-srcs = lib.filterAttrs (name: _:
    lib.hasPrefix "valence-contracts" name
  ) inputs;
  getVersion = lib.removePrefix "valence-contracts-";
in

{
  perSystem = {
    valence-contracts.builds =
      lib.mapAttrs
        (name: input: {
          src = input;
          version = getVersion name;
        })
        valence-contracts-srcs;
  };
}
