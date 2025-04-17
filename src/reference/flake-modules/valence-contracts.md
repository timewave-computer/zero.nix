# Valence Contracts

[`valence-contracts`](https://github.com/timewave-computer/zero.nix/blob/main/flakeModules/valence-contracts.nix)
is a flake-parts module that sets up all valence contracts to be uploaded for the latest release to be consumed by the [`upload-contracts`](./upload-contracts.md) module. It can also create packages for any number of
[valence-protocol](https://github.com/timewave-computer/valence-protocol)
versions with the `builds` option. This feature is used by zero.nix itself to provide packages for all
[valence-protocol](https://github.com/timewave-computer/valence-protocol)
releases and the main branch.
# 





## Installation

To use these options, add to your flake inputs:

```nix
valence-contracts.url = "github:timewave-computer/zero.nix";
```

and inside the `mkFlake`:


```nix
imports = [
  inputs.valence-contracts.flakeModules.valence-contracts
];
```

Run `nix flake lock` and you're set.

## Options

## perSystem\.valence-contracts\.builds {#opt-perSystem.valence-contracts.builds}

Valence contract builds to add to packages output\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.builds\.\<name>\.packages {#opt-perSystem.valence-contracts.builds._name_.packages}



Manually specified list of cargo packages to build contracts for\.
When specified, ` contracts-dir ` option will be ignored\.



*Type:*
null or (list of string)



*Default:*
` "null, which will cause all contracts found in folder specified by contracts-dir option to be built" `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.builds\.\<name>\.contracts-dir {#opt-perSystem.valence-contracts.builds._name_.contracts-dir}



Folder where contract packages are located\.
All cargo packages within folder will be built\.



*Type:*
string



*Default:*
` "contracts" `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.builds\.\<name>\.rust-version {#opt-perSystem.valence-contracts.builds._name_.rust-version}



Rust version to build contracts with\.



*Type:*
string



*Default:*
` "1.81.0" `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.builds\.\<name>\.src {#opt-perSystem.valence-contracts.builds._name_.src}



Source to build valence contracts from\.
Could be a flake input or the result of ` builtins.fetchGit `\.



*Type:*
absolute path

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.builds\.\<name>\.version {#opt-perSystem.valence-contracts.builds._name_.version}



Valence protocol version thats being built\.
Only used to name resulting package\.



*Type:*
string



*Default:*
` ${name} `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)



## perSystem\.valence-contracts\.upload {#opt-perSystem.valence-contracts.upload}



Whether to enable Setup all valence contracts from latest stable release to be uploaded\.
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [valence-contracts\.nix](https://github.com/timewave-computer/zero.nix/blob/main.nix)

