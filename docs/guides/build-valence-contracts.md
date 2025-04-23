# Build Valence Contracts

Zero.nix contains a flake module [`valence-contracts`](../reference/flake-modules/valence-contracts.md)
that exports packages for valence contracts.
Zero.nix uses this module to export packages for all releases and the main branch of valence-protocol contracts.

## Example

Here is an example of a flake that creates a package for valence-protocol contracts from the latest main revision.

```nix
{{#include ../../templates/build-valence-contracts/flake.nix}}
``` 

The resulting package can then be built with 
```bash
nix build .#valence-contracts-main
```

## Adding versions to zero.nix

Supposing that valence-protocol version X.Y.Z was just released,
the package for that version's contracts would have to be added
to this repository.

First add the add the input for the tag to the flake.nix, by
addling these two lines inside the `inputs` section.
```nix
  inputs = {
    valence-contracts-vX_Y_Z.url = "github:timewave-computer/valence-protocol/vX.Y.Z";  
    valence-contracts-vX_Y_Z.flake = false;
  };
```

The `valence-contracts` package file will automatically export
contract packages for all inputs starting with
"valence-contracts", so the package can immediately be built
once the input is added with the following command:
```bash
nix build .#valence-contracts-vX_Y_Z
```
This command can take up to 30 min depending on the machine its run in.

To then make use of the package, be sure to update the zero.nix
input of any flake depending on zero.nix
If the input is called `zero-nix` in the flake then run:
```bash
nix flake update zero-nix
```

