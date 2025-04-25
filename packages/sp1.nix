{
  lib,
  sp1-rust,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  openssl,
  ...
}:
rustPlatform.buildRustPackage {
  pname = "sp1";
  version = "unstable-2025-03-06";

  nativeBuildInputs = [
    sp1-rust
    pkg-config
    openssl
  ];
  cargoBuildFlags = [ "--package sp1-cli" ];
  cargoHash = "sha256-gI/N381IfIWnF4tfXM1eKLI93eCjEELg/a5gWQn/3EA=";

  src = fetchFromGitHub {
    owner = "succinctlabs";
    repo = "sp1";
    rev = "9f202bf603b3cab5b7c9db0e8cf5524a3428fbee";
    hash = "sha256-RpllsIlrGyYw6dInN0tTs7K1y4FiFmrxFSyt3/Xelkg=";
    fetchSubmodules = true;
  };
  doCheck = false;
}
