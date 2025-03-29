{ pkgs, crane, rust-overlay }:

{ src
, version
, contractsDir ? "contracts"
, packages ? null
, rustVersion ? "1.81.0" # same as cosmwasm/optimizer
}:

pkgs.callPackage ./cosmwasm-contracts.nix {
  inherit
    rust-overlay
    crane
    version
    src
    packages
    contractsDir
    rustVersion
  ;
}
