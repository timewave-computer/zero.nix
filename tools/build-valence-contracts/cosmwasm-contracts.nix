{ lib
, crane
, rust-overlay
, pkgs
, src
, packages
, contracts-dir
, version
, rust-version
, binaryen
}:
let
  rustPkgs = pkgs.appendOverlays [
    rust-overlay.overlays.rust-overlay
  ];

  craneLib =
    if rust-version == null then crane.mkLib pkgs
    else (crane.mkLib rustPkgs).overrideToolchain (p: p.rust-bin.stable.${rust-version}.default.override {
      targets = [ "wasm32-unknown-unknown" ];
    });

  contractCargoTomls = lib.filter
    (lib.hasSuffix "Cargo.toml")
    (lib.filesystem.listFilesRecursive "${src}/${contracts-dir}");
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
  '';

  buildContractPackage = contract:
    craneLib.buildPackage (cargoArtifacts.commonArgs // {
      pname = "valence-contract-${contract}";
      inherit cargoArtifacts;
      passthru = { inherit cargoArtifacts; };
      nativeBuildInputs = cargoArtifacts.commonArgs.nativeBuildInputs ++ [
        binaryen
      ];
      cargoExtraArgs = "-p ${contract} --lib --locked";
      inherit postInstall;
    });

  contractPackages = lib.genAttrs contractNames buildContractPackage;

  drvArgs = {
    inherit src;
    passthru.contracts = contractPackages;
  };

  symlinkContract = contract:
    let
      contractPath = "${lib.replaceStrings [ "-" ] [ "_" ] contract}.wasm";
    in ''
      ln -s ${contractPackages.${contract}}/${contractPath} $out/${contractPath}
    '';

in
pkgs.runCommandLocal "valence-contracts-${version}" drvArgs ''
  mkdir -p $out
  ${lib.concatStringsSep "\n" (lib.map symlinkContract contractNames)}

  cd $out # so that sha256sum prints paths without /nix/store/...
  echo "Post-processing artifacts..."
  sha256sum -- *.wasm | tee $out/checksums.txt
''
