# Upload Contracts

[`upload-contracts`](https://github.com/timewave-computer/zero.nix/blob/main/flakeModules/upload-contracts/default.nix)
is a flake-parts module that creates runnables that will upload cosmwasm contracts to networks of chains.

## Example

The following example example shows how to configure the
upload for valence_processor and valence_base_account contracts 
to neutron and juno.

```nix
{{#include uploading-contracts.nix}}
```

This flake will now have multiple runnables in the `apps` output
with scripts to upload contracts to all chains.
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

## perSystem\.upload-contracts\.networkDefaults {#opt-perSystem.upload-contracts.networkDefaults}

Default settings to merge into all networks\.
Options are the same as the ones for each network\.
Since this is a module it can dynamically reference network specific names and configuration as seen in the example\.



*Type:*
module



*Default:*
` { } `



*Example:*

```
{ name, ... }: {
  data-dir = "./${name}/contracts-data";
}

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks {#opt-perSystem.upload-contracts.networks}



Networks to upload contracts to\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chainDefaults {#opt-perSystem.upload-contracts.networks._name_.chainDefaults}



Default settings for all chains\.



*Type:*
module



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains {#opt-perSystem.upload-contracts.networks._name_.chains}



Chains to upload contracts to\.



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.package {#opt-perSystem.upload-contracts.networks._name_.chains._name_.package}



Package with node command for chain\.



*Type:*
package



*Default:*

```
cosmos-nix.packages.${name}

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.admin-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.admin-address}



Admin address to use for contracts;



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.chain-id {#opt-perSystem.upload-contracts.networks._name_.chains._name_.chain-id}



Unique chain ID\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.command {#opt-perSystem.upload-contracts.networks._name_.chains._name_.command}



Chain command to use for all operations\.



*Type:*
absolute path



*Default:*

```
"${package}/bin/${package.meta.mainProgram}"

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contractDefaults {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contractDefaults}



Default settings to merge into all contracts



*Type:*
module



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts}



Default settings to merge into all contracts



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.package {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.package}



Package where contract is stored\.
Only used to automatically set ` path ` and ` source ` options\.



*Type:*
package

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.initial-state {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.initial-state}



Initial state to pass to contract when instantiating\.
Only used if ` instantiat ` is also set\.



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.instantiate {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.instantiate}



Whether or not to instantiate contract\.



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.path {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.path}



Location of contract\.



*Type:*
absolute path



*Default:*

```
"${package}/${name}.wasm"

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.contracts\.\<name>\.source {#opt-perSystem.upload-contracts.networks._name_.chains._name_.contracts._name_.source}



Text to indicate where contract is sourced from\. Could be a git revision, url, or local path\.



*Type:*
string



*Default:*

````
`package.src.rev` if it exists, otherwise absolute path of contract

````

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.data-file {#opt-perSystem.upload-contracts.networks._name_.chains._name_.data-file}



File where data about uploaded contracts will be stored\.



*Type:*
string



*Default:*

```
"${data-dir}/${name}.yaml"

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.denom {#opt-perSystem.upload-contracts.networks._name_.chains._name_.denom}



Denom to use when submitting transactions on chain\.



*Type:*
string



*Default:*
` "" `



*Example:*
` "uatom" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.from-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.from-address}



The account that transactions should be sent from\.
The private key for this account will need to be available in the
keyring specified in the ` keyring ` option\.



*Type:*
string



*Default:*
` admin-address `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.gas-multiplier {#opt-perSystem.upload-contracts.networks._name_.chains._name_.gas-multiplier}



This number will be multiplied to the estimated gas computed for any transaction\.



*Type:*
floating point number



*Default:*
` 1.5 `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.keyring-backend {#opt-perSystem.upload-contracts.networks._name_.chains._name_.keyring-backend}



Keyring backend to use\.



*Type:*
string



*Default:*
` "test" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.max-fees {#opt-perSystem.upload-contracts.networks._name_.chains._name_.max-fees}



Maximum fees allowed for any transaction\.



*Type:*
string



*Default:*
` "" `



*Example:*
` "1000000" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.chains\.\<name>\.node-address {#opt-perSystem.upload-contracts.networks._name_.chains._name_.node-address}



RPC address of node to use for all chain operations\.



*Type:*
string



*Default:*
` "" `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.data-dir {#opt-perSystem.upload-contracts.networks._name_.data-dir}



Folder where data about uploaded contracts should be stored\.



*Type:*
string



*Default:*

```
"${name}-contracts";

```

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)



## perSystem\.upload-contracts\.networks\.\<name>\.program-manager-chains-toml {#opt-perSystem.upload-contracts.networks._name_.program-manager-chains-toml}



Chains\.toml file in format used for valence program manager
to pull default chain information from\.



*Type:*
null or absolute path



*Default:*
` null `

*Declared by:*
 - [upload-contracts/default\.nix](https://github.com/timewave-computer/zero.nix/blob/main/default.nix)

