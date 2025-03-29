{ inputs, lib, ... }:
{
  perSystem = { pkgs, config, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
    }
    // (import ./valence-contracts.nix {
      inherit (config.tools) buildValenceContracts;
      inherit lib inputs;
    });
  };
}
