{
  imports = [
    ./valence-contracts.nix
    ./ethereum.nix
  ];
  perSystem = { pkgs, config, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
      local-ic = pkgs.callPackage ./local-ic.nix {};
      sp1-rust = pkgs.callPackage ./sp1-rust.nix {};
      sp1 = pkgs.callPackage ./sp1.nix {
        inherit (config.packages) sp1-rust;
      };
    };
  };
}
