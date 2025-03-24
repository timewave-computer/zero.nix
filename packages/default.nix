{
  perSystem = { pkgs, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
      # Import ethereum-tools attributes directly
      foundry-installer = (pkgs.callPackage ./ethereum-tools {}).foundry-installer;
      foundry-forge = (pkgs.callPackage ./ethereum-tools {}).foundry-forge;
      foundry-anvil = (pkgs.callPackage ./ethereum-tools {}).foundry-anvil;
      foundry-cast = (pkgs.callPackage ./ethereum-tools {}).foundry-cast;
      foundry-chisel = (pkgs.callPackage ./ethereum-tools {}).foundry-chisel;
    };
  };
}
