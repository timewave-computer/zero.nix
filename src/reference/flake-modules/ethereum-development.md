# 





## Installation

To use these options, add to your flake inputs:

```nix
ethereum-development.url = "github:timewave-computer/zero.nix";
```

and inside the `mkFlake`:


```nix
imports = [
  inputs.ethereum-development.flakeModules.ethereum-development
];
```

Run `nix flake lock` and you're set.

## Options

## perSystem\.ethereum-development\.enable {#opt-perSystem.ethereum-development.enable}

Whether to enable ethereum development environment\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [ethereum-development/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.ethereum-development\.network {#opt-perSystem.ethereum-development.network}



Default ethereum network for development



*Type:*
one of “mainnet”, “goerli”, “sepolia”, “holesky”



*Default:*
` "sepolia" `

*Declared by:*
 - [ethereum-development/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)

