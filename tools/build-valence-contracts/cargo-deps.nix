{ lib
, craneLib
, cargoVendorDir
, pkg-config
, coreutils
, findutils
, openssl
, libclang
, clang
, llvm
, lld
, contractNames
, version
, src
}:
let
  commonArgs = {
    inherit src cargoVendorDir version;

    pname = "valence-contracts";

    strictDeps = true;
    doCheck = false;
    dontStrip = true;

    LIBCLANG_PATH = lib.makeLibraryPath [ libclang ];

    CARGO_BUILD_TARGET = "wasm32-unknown-unknown";

    cargoExtraArgs = "-p ${lib.concatStringsSep " -p " contractNames} --lib --locked";

    buildInputs = [
      openssl
    ];

    nativeBuildInputs = [
      pkg-config
      coreutils
      findutils
      clang
      llvm
      lld
    ];
  };
in
craneLib.buildDepsOnly (commonArgs // {
  passthru = { inherit commonArgs; };
})
