{
  imports = [
    ./valence-contracts.nix
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
    
    devShells.default = pkgs.mkShell {
      name = "zero-nix-dev";
      buildInputs = with pkgs; [
        # Basic development tools
        git
        curl
        jq
        
        # Nix tools
        nix-prefetch-git
        
        # Build tools
        pkg-config
        
        # Include our custom packages
        config.packages.upload-contract
      ];
      
      shellHook = ''
        echo "Welcome to zero.nix development environment"
        echo "Available packages: upload-contract, local-ic, sp1-rust, sp1"
      '';
    };
  };
}
