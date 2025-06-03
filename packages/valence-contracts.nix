{
  self,
  inputs,
  ...
}: {
  perSystem = {
    valence-contracts.default-inputs = {
      zero-nix = self;
      cosmos-nix = inputs.cosmos-nix;
    };
    valence-contracts.builds = {
      valence-contracts-v0_1_1 = {
        src = inputs.valence-contracts-v0_1_1;
        version = "v0_1_1";
      };
      valence-contracts-v0_1_2 = {
        src = inputs.valence-contracts-v0_1_2;
        version = "v0_1_2";
      };
      valence-contracts-main = {
        src = inputs.valence-contracts-main;
        version = "main";
        rust-version = "1.85.0";
      };
    };
  };
}
