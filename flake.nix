{
  nixConfig = {
    extra-substituters = "https://timewave.cachix.org";
    extra-trusted-public-keys = ''
      timewave.cachix.org-1:nu3Uqsm3sikI9xFK3Mt4AD4Q6z+j6eS9+kND1vtznq4=
    '';
  };

  description = "A nix based factory for creating chains";

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
      imports = [
        ./flakeModules/default.nix
        ./nixosModules/default.nix
        ./packages/default.nix
      ];
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    cosmos-nix.url = "github:timewave-computer/cosmos.nix";
    flake-parts.url = "github:hercules-ci/flake-parts";
    crane.url = "github:ipetkov/crane";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };
}
