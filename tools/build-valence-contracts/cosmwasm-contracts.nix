{ lib
, crane
, rust-overlay
, binaryen
, pkgs
, src
, packages
, contractsDir
, version
, rustVersion ? "1.81.0" # same as cosmwasm/optimizer
}:
let
  rustPkgs = pkgs.appendOverlays [
    rust-overlay.overlays.rust-overlay
  ];

  craneLib =
    if rustVersion == null then crane.mkLib pkgs
    else (crane.mkLib rustPkgs).overrideToolchain (p: p.rust-bin.stable.${rustVersion}.default.override {
      targets = [ "wasm32-unknown-unknown" ];
    });

  contractCargoTomls = lib.filter
    (lib.hasSuffix "Cargo.toml")
    (lib.filesystem.listFilesRecursive "${src}/${contractsDir}");
  getCrateNameFromPath = path:
    let
      cargoTomlCrate = builtins.fromTOML (builtins.readFile path);
    in
      cargoTomlCrate.package.name or null;

  contractNames =
    if packages == null then
      lib.filter (x: x != null) (lib.map getCrateNameFromPath contractCargoTomls)
    else
      packages;

  cargoVendorDir = pkgs.callPackage ./cargo-vendor-dir.nix {
    inherit craneLib src;
  };

  cargoArtifacts = pkgs.callPackage ./cargo-deps.nix {
    inherit cargoVendorDir contractNames craneLib version src;
  };

in
craneLib.buildPackage (cargoArtifacts.commonArgs // {
  inherit cargoArtifacts;
  passthru = { inherit cargoArtifacts; };
  nativeBuildInputs = cargoArtifacts.commonArgs.nativeBuildInputs ++ [
    binaryen
  ];
  # Based on CosmWasm optimizer optimize.sh
  postInstall = ''
    for WASM in $out/lib/*.wasm; do
      [ -e "$WASM" ] || continue # https://superuser.com/a/519493

      OUT_FILENAME=$(basename "$WASM")
      echo "Optimizing $OUT_FILENAME ..."
      # --signext-lowering is needed to support blockchains runnning CosmWasm < 1.3. It can be removed eventually
      wasm-opt -Os --signext-lowering "$WASM" -o "$out/$OUT_FILENAME"
    done

    rm -rf $out/lib

    echo "Post-processing artifacts..."
    sha256sum -- $out/*.wasm | tee $out/checksums.txt
  '';
})
