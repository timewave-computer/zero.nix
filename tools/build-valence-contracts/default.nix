{ pkgs, crane, rust-overlay }:

{ src
, version
, contracts-dir ? "contracts"
, packages ? null
, rust-version ? "1.81.0" # same as cosmwasm/optimizer
}:

pkgs.callPackage ./cosmwasm-contracts.nix {
  inherit
    rust-overlay
    crane
    version
    src
    packages
    contracts-dir
    rust-version
  ;
}
