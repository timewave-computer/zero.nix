{
  perSystem = { pkgs, ... }: {
    packages = {
      upload-contract = pkgs.callPackage ./upload-contract {};
    };
  };
}
