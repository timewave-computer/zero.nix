{
  stdenv,
  autoPatchelfHook,
  fixDarwinDylibNames,
  fetchzip,
  zlib,
  ...
}:
let
  fetchGitHubReleaseAsset =
    {
      owner,
      repo,
      tag,
      asset,
      hash,
    }:
    fetchzip {
      url = "https://github.com/${owner}/${repo}/releases/download/${tag}/${asset}";
      inherit hash;
      stripRoot = false;
    };

in
stdenv.mkDerivation rec {
  name = "sp1-rust";
  version = "1.82.0";

  nativeBuildInputs = [
    stdenv.cc.cc.lib
    zlib
  ] ++ (if stdenv.isDarwin then [ fixDarwinDylibNames ] else [ autoPatchelfHook ]);

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./* $out/
    runHook postInstall
  '';

  src = fetchGitHubReleaseAsset ({
    owner = "succinctlabs";
    repo = "rust";
    tag = "succinct-${version}";
  } // {
    "x86_64-linux" = {
      asset = "rust-toolchain-x86_64-unknown-linux-gnu.tar.gz";
      hash = "sha256-wXI2zVwfrVk28CR8PLq4xyepdlu65uamzt/+jER2M2k=";
    };
    "aarch64-linux" = {
      asset = "rust-toolchain-aarch64-unknown-linux-gnu.tar.gz";
      hash = "";
    };
    "x86_64-darwin" = {
      asset = "rust-toolchain-x86_64-apple-darwin.tar.gz";
      hash = "sha256-sPQW8eo+qItsmgK1uxRh1r73DBLUXUtmtVUvjacGzp0=";
    };
    "aarch64-darwin" = {
      asset = "rust-toolchain-aarch64-apple-darwin.tar.gz";
      hash = "sha256-R4D7hj2DcZ3vfCejvXwJ68YDOlgWGDPcb08GZNXz1Cg=";
    };
  }.${stdenv.system});
}
