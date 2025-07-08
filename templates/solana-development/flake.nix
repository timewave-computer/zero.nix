{
  description = "Solana development environment using zero.nix";

  nixConfig.extra-experimental-features = "nix-command flakes";
  nixConfig.extra-substituters = "https://timewave.cachix.org";
  nixConfig.extra-trusted-public-keys = ''
    colmena.cachix.org-1:7BzpDnjjH8ki2CT3f6GdOk7QAzPOl+1t3LvTLXqYcSg=
    cosmos-nix.cachix.org-1:I9dmz4kn5+JExjPxOd9conCzQVHPl0Jo1Cdp6s+63d4=
    nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=
  '';

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    
    flake-parts.url = "github:hercules-ci/flake-parts";
    
    devshell.url = "github:numtide/devshell";
    
    zero-nix.url = "github:timewave-computer/zero.nix";
  };

  outputs = {
    self,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.devshell.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];

      perSystem = {
        pkgs,
        inputs',
        ...
      }: {
        devshells.default = {pkgs, ...}: {
          commands = [
            {package = inputs'.zero-nix.packages.solana-tools;}
            {package = inputs'.zero-nix.packages.setup-solana;}
          ];
          
          devshell.startup.setup-solana = {
            deps = [];
            text = ''
              echo "🌞 Solana development environment using zero.nix"
              echo "Available tools:"
              echo "  - solana CLI (v2.0.22)"
              echo "  - anchor CLI (v0.31.1)"
              echo "  - platform tools (v1.48)"
              echo "  - cargo-build-sbf"
              echo ""
              echo "Run 'setup-solana' to initialize the development environment"
              echo "Create a new Anchor project with: anchor init my-project"
              echo ""
            '';
          };
        };
      };
    };
} 