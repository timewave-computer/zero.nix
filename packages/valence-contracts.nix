{ buildValenceContracts
, inputs
, lib
}:
let
  valence-contracts-srcs = lib.filterAttrs (name: _:
    lib.hasPrefix "valence-contracts" name
  ) inputs;
  getVersion = lib.removePrefix "valence-contracts-";
in
lib.mapAttrs (name: input:
  buildValenceContracts {
    src = input;
    version = getVersion name;
  }
) valence-contracts-srcs
// {
  valence-contracts-generic-ibc = buildValenceContracts {
    src = inputs.valence-contracts-v0_1_2;
    version = "v0.1.2";
    packages = [ "valence-generic-ibc-transfer-library" ];
  };
}
