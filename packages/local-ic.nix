{ buildGoModule
, fetchFromGitHub
}:
buildGoModule {
  pname = "local-ic";
  version = "8.5.0";
   src = fetchFromGitHub {
    owner = "strangelove-ventures";
    repo = "interchaintest";
    rev = "v8.5.0";
    hash = "sha256-NKp0CFPA593UNG/GzMQh7W/poz1/dESrqlRG8VQVxUk=";
  };
  subPackages = [ "local-interchain/cmd/local-ic" ];
  proxyVendor = true; # Ensures dependencies are vendored correctly.
  vendorHash = "sha256-NWq2/gLMYZ7T5Q8niqFRJRrfnkb0CjipwPQa4g3nCac=";
}
