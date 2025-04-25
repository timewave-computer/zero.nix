# ZK Development

Zero.nix provides the `sp1` and `sp1-rust` packages to make it
easy to setup a nix development shell with sp1 tooling.

To use them create a flake.nix with the following contents:
```nix
{{#include ../../templates/zk-development/flake.nix}}
```
You can also run the following command to initialize the template.
```bash
nix flake init -t github:timewave-computer/zero.nix#zk-dev

```

Then run `nix develop` to enter a devshell with the packages.


