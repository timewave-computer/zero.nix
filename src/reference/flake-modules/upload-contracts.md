# 





## Installation

To use these options, add to your flake inputs:

```nix
upload-contracts.url = "github:timewave-computer/zero.nix";
```

and inside the `mkFlake`:


```nix
imports = [
  inputs.upload-contracts.flakeModules.upload-contracts
];
```

Run `nix flake lock` and you're set.

## Options

## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.package {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.admin-address {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.admin-address}

*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.chain-id {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.chain-id}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.command {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.command}



*Type:*
absolute path



*Default:*
` "\${config.package}/bin/\${config.package.meta.mainProgram}" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults}



*Type:*
submodule

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults\.package {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults\.initial-state {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults.initial-state}



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults\.instantiate {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults.instantiate}



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults\.path {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults.path}



*Type:*
absolute path



*Default:*
` "\${config.package}/\${name}.wasm" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contractDefaults\.source {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contractDefaults.source}



*Type:*
string



*Default:*
` "config.package.src.rev if it exists, otherwise config.path" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts}



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts\.\<name>\.package {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts._name_.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts\.\<name>\.initial-state {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts._name_.initial-state}



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts\.\<name>\.instantiate {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts._name_.instantiate}



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts\.\<name>\.path {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts._name_.path}



*Type:*
absolute path



*Default:*
` "\${config.package}/\${name}.wasm" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.contracts\.\<name>\.source {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.contracts._name_.source}



*Type:*
string



*Default:*
` "config.package.src.rev if it exists, otherwise config.path" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.data-file {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.data-file}



*Type:*
string



*Default:*
` "‹name›-contracts/‹name›.yaml" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.denom {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.denom}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.from-address {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.from-address}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.gas-multiplier {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.gas-multiplier}



*Type:*
floating point number



*Default:*
` 1.5 `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.keyring-backend {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.keyring-backend}



*Type:*
string



*Default:*
` "test" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.max-fees {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.max-fees}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults\.node-address {#opt-perSystem.upload-contracts.networks._name_.chainDefaults.node-address}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.package {#opt-perSystem.upload-contracts.networks._name_.chains._name_.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.admin-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.admin-address}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.chain-id {#opt-perSystem.upload-contracts.networks._name_.chains._name_.chain-id}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.command {#opt-perSystem.upload-contracts.networks._name_.chains._name_.command}



*Type:*
absolute path



*Default:*
` "\${config.package}/bin/\${config.package.meta.mainProgram}" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults}



*Type:*
submodule

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults\.package {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults\.initial-state {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults.initial-state}



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults\.instantiate {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults.instantiate}



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults\.path {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults.path}



*Type:*
absolute path



*Default:*
` "\${config.package}/\${name}.wasm" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults\.source {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults.source}



*Type:*
string



*Default:*
` "config.package.src.rev if it exists, otherwise config.path" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts}



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.package {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.package}



*Type:*
package

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.initial-state {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.initial-state}



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.instantiate {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.instantiate}



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.path {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.path}



*Type:*
absolute path



*Default:*
` "\${config.package}/\${name}.wasm" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.source {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.source}



*Type:*
string



*Default:*
` "config.package.src.rev if it exists, otherwise config.path" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.data-file {#opt-perSystem.upload-contracts.networks._name_.chains._name_.data-file}



*Type:*
string



*Default:*
` "‹name›-contracts/‹name›.yaml" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.denom {#opt-perSystem.upload-contracts.networks._name_.chains._name_.denom}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.from-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.from-address}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.gas-multiplier {#opt-perSystem.upload-contracts.networks._name_.chains._name_.gas-multiplier}



*Type:*
floating point number



*Default:*
` 1.5 `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.keyring-backend {#opt-perSystem.upload-contracts.networks._name_.chains._name_.keyring-backend}



*Type:*
string



*Default:*
` "test" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.max-fees {#opt-perSystem.upload-contracts.networks._name_.chains._name_.max-fees}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.node-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.node-address}



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/upload-contracts/chain-opts\.nix](https://github.com/timewave-computer/zero.nix/blob/main/upload-contracts/chain-opts.nix)

