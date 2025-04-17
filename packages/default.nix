{ inputs, lib, ... }:
{
  imports = [
    ./valence-contracts.nix
  ];
  perSystem = { pkgs, config, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
      local-ic = pkgs.callPackage ./local-ic.nix {};
    };
  };
}
