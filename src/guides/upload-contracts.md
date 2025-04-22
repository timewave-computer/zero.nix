# Upload Contracts

Zero.nix provides the flake module
[`upload-contracts`](../reference/flake-modules/valence-contracts.md)
to automate the process of uploading contracts to cosmos based
chains.

## Example

Here is an example of a flake.nix that exports scripts to upload
valence_processor and valence_base_account contracts to neutron and juno.

```nix
{{#include ../../templates/upload-contracts/flake.nix}}
```

To then make use of the scripts use `nix run`.
Code IDs will be printed out in toml format.

### Upload contracts to an individual chain

Run `nix run .#<network>-<chain>-upload-contracts`.

For example, to upload neutron mainnet contracts run the following:

``` bash
nix run .#mainnet-neutron-upload-contracts -- --admin-address <admin-address>
```
Code ids will be printed out at the end in toml format.

### Upload contracts to a network of chains

To upload all contracts for every chain in a network use:

``` bash
nix run .#mainnet-upload-contracts -- --admin-address <admin-key-name>
```
This script will create a `contracts.toml` for the whole network in `mainnet-contracts/contracts.toml`.

The uploading process doesn't yet support command line arguments per chain, so when uploading a network of chains it is recommended to have addresses with the same key name for all chains and then pass the key name as the admin address.

If it is necessary to specify different admin addresses per chain, then it must be set in flake.nix with the `admin-address` key. To override the mainnet neutron admin-address, for example, go to the "networks.mainnet.chains" section of flake.nix and set admin-address like so:

``` nix
networks.mainnet.chains = {
  neutron = {
    admin-address = "neutron1...";
```

### Customizing contract uploads

The contract uploading script can be passed various arguments similar to how the admin address was passed above. To see all the arguments of the script run:

``` bash
nix run github:timewave-computer/zero.nix#upload-contract -- --help
```
Note: all options have to be passed after the "--" to ensure they get passed to the script instead of the nix command.

Every option has an equivalent environment variable as described in the help menu. These variables can optionally be set in flake.nix for declarative configuration. Options passed in the command line will always override settings in environment variables (or set through nix).

As an example, to upload neutron contracts with a different rpc, run:

``` bash
nix run .#mainnet-neutron-upload-contracts --admin-address <admin-address> --node-address <rpc url>
```

### Manually print code ids
A script is available to print the code ids of any collection of chains. To do so, run:

``` bash
nix run .#print-contracts-toml <chain yaml files>
```
The chain yaml files are the ones living in the contracts-data folder created by the upload scripts.

For example, to print the contracts.toml for contracts on just neutron and juno on mainnet, run:

``` bash
nix run .#print-contracts-toml mainnet/contracts-data/neutron.yaml mainnet/contracts-data/juno.yaml 
```
