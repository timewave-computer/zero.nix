# Valence Contracts

[`valence-contracts`](https://github.com/timewave-computer/zero.nix/blob/main/flakeModules/valence-contracts.nix)
is a flake-parts module that sets up all valence contracts to be uploaded for the latest release to be consumed by the [`upload-contracts`](./upload-contracts.md) module. It can also create packages for any number of
[valence-protocol](https://github.com/timewave-computer/valence-protocol)
versions with the `builds` option. This feature is used by zero.nix itself to provide packages for all
[valence-protocol](https://github.com/timewave-computer/valence-protocol)
releases and the main branch.
