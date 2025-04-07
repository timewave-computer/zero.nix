{ inputs, lib, ... }:
{
  perSystem = { pkgs, config, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
      local-ic = pkgs.callPackage ./local-ic.nix {};
    }
    // (import ./valence-contracts.nix {
      inherit (config.tools) buildValenceContracts;
      inherit lib inputs;
    });
  };
}
