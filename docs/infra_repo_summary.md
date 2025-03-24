# Infra Repository Summary

## Overview

The `github.com/timewave-computer/infra` repository is a Nix-based infrastructure configuration for deploying and managing blockchain networks, primarily focused on setting up a Zero-Knowledge (ZK) simulation environment. It showcases how zero.nix is used in practice to create and manage a multi-chain testing environment with Cosmos-based blockchains.

## Repository Purpose

The main purpose of this repository is to:

1. Provide a reproducible deployment configuration for a ZK simulation environment
2. Demonstrate integration of multiple Cosmos chains in a single environment
3. Configure IBC communication between chains via Hermes relayer
4. Deploy smart contracts automatically as part of node initialization
5. Standardize configuration across multiple blockchain nodes

## File Structure

```
infra/
├── .git/
├── .envrc                  # direnv configuration for Nix development
├── README.md               # Basic repository information
├── devshell.nix            # Development shell configuration
├── flake.lock              # Lock file with exact dependency versions
├── flake.nix               # Main Nix flake configuration
├── hosts/                  # Host-specific configurations
│   └── zk-sim.nix          # ZK simulation environment host configuration
├── profiles/               # Reusable configuration profiles
│   ├── default-genesis-accounts.nix  # Default accounts for all chains
│   ├── default-node-settings.nix     # Default settings for all nodes
│   ├── gaia.nix                      # Cosmos Hub (Gaia) chain configuration
│   ├── hermes.nix                    # Hermes relayer configuration
│   ├── juno.nix                      # Juno chain configuration
│   ├── neutron.nix                   # Neutron chain configuration
│   ├── osmosis.nix                   # Osmosis chain configuration
│   └── sp1-verifier-contracts/       # Smart contracts to be deployed
│       ├── default.nix               # Contract deployment configuration
│       ├── cw_sp1_verifier-groth16.wasm  # Groth16 verifier contract
│       └── cw_sp1_verifier-plonk.wasm    # PLONK verifier contract
└── ssh-public-keys/        # SSH keys for server access
```

## Zero.nix Integration

The infra repository uses zero.nix as a core dependency to provide NixOS modules and tools for blockchain infrastructure deployment. The integration is established in several key files:

### 1. flake.nix

```nix
# In flake.nix
inputs = {
  nixpkgs.url = "nixpkgs/nixos-24.11";
  flake-parts.url = "github:hercules-ci/flake-parts";
  haumea.url = "github:nix-community/haumea";
  devshell.url = "github:numtide/devshell";
  colmena.url = "github:zhaofengli/colmena";
  cosmos-nix.url = "github:timewave-computer/cosmos.nix";
  zero-nix.url = "github:timewave-computer/zero.nix"; // Zero.nix imported here
};

# Later in the file:
flake.colmena = {
  defaults = moduleWithSystem ({ inputs', self'}:
    {lib, ...}: {
      imports = [
        inputs.zero-nix.nixosModules.hermes // Zero.nix Hermes module imported 
        inputs.zero-nix.nixosModules.cosmos-nodes // Zero.nix Cosmos nodes module imported
      ];
      _module.args = {
        inherit inputs inputs';
        self = self // self';
      };
    }
  );
};
```

### 2. hosts/zk-sim.nix

The ZK simulation host config imports various profiles that configure different blockchain nodes:

```nix
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ../profiles/gaia.nix
    ../profiles/neutron.nix
    ../profiles/juno.nix
    ../profiles/osmosis.nix
    ../profiles/default-node-settings.nix
    ../profiles/sp1-verifier-contracts/default.nix
    ../profiles/default-genesis-accounts.nix
    ../profiles/hermes.nix
  ];
  
  # Host-specific configuration follows...
}
```

### 3. Individual Chain Profiles

Each chain profile (e.g., profiles/gaia.nix) uses zero.nix's cosmos-node module to configure a specific blockchain node:

```nix
# profiles/gaia.nix
{ inputs', ... }:
let
  inherit (inputs'.cosmos-nix.packages) gaia20;
in
{
  # Using zero.nix's cosmos-node module through the services.cosmos.nodes namespace
  services.cosmos.nodes.gaia = {
    chain-id = "sim-cosmoshub-1";
    command = "${gaia20}/bin/gaiad";
    genesisSubcommand = "genesis";
    denom = "uatom";
    bech32-prefix = "cosmos";
    minimum-gas-price.price = 0.005;
  };
}
```

### 4. Hermes Configuration

The Hermes IBC relayer is configured using zero.nix's hermes module:

```nix
# profiles/hermes.nix
{ inputs', ... }:
{
  # Using zero.nix's hermes module
  services.cosmos.hermes.enable = true;
  services.cosmos.hermes.package = inputs'.cosmos-nix.packages.hermes;
}
```

### 5. Contract Deployment

Zero.nix's contract deployment capabilities are used to automatically deploy WASM contracts:

```nix
# profiles/sp1-verifier-contracts/default.nix
{
  services.cosmos.nodeDefaults.contracts = {
    cw_sp1_verifier-groth16.path = ./cw_sp1_verifier-groth16.wasm;
    cw_sp1_verifier-plonk.path = ./cw_sp1_verifier-plonk.wasm;
  };
}
```

### 6. Default Node Settings

Common settings for all nodes are configured using zero.nix's nodeDefaults option:

```nix
# profiles/default-node-settings.nix
{
  services.cosmos.nodeDefaults = {
    appSettings = {
      wasm.query_gas_limit = 100000000000000;
    };
    settings = {
      rpc = {
        cors_allowed_origins = [ "*" ];
      };
    };
  };
}
```

### 7. Genesis Accounts

Test accounts are created using zero.nix's genesisAccounts option:

```nix
# profiles/default-genesis-accounts.nix
{ config, lib, pkgs, ... }:

{
  services.cosmos.nodeDefaults.genesisAccounts =
   (lib.listToAttrs (lib.genList (n: {
     name = "acc${toString n}";
     value.amount = "10000000000000000000000000000000000";
   }) 30)) //
   (lib.listToAttrs (lib.genList (n: {
     name = "faucet${toString n}";
     value.amount = "10000000000000000000000000000000000000000000000000000000000000000000";
   }) 15));
}
```

## Deployment Pattern

The infra repository uses [Colmena](https://github.com/zhaofengli/colmena) for deploying NixOS configurations to remote servers:

```nix
# From flake.nix
flake.colmenaHive = inputs.colmena.lib.makeHive self.colmena;

flake.colmena = {
  meta = {
    nixpkgs = import inputs.nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
    };
  };

  defaults = /* ... */ ;
  
  zk-simulation-environment = {...}: {
    deployment = {
      targetUser = "root";
      targetHost = "174.138.69.72";
    };

    imports = [
      ./hosts/zk-sim.nix
    ];
  };
};
```

This structure allows for deployment of the complete ZK simulation environment to a specific host (174.138.69.72) using a single command.

## How Zero.nix is Used

In summary, the infra repository uses zero.nix in the following ways:

1. **Modular Configuration**: Zero.nix's NixOS modules provide a modular way to configure various blockchain components
2. **Standardization**: The nodeDefaults mechanism allows for standardized configuration across all nodes
3. **Chain Deployment**: Each Cosmos chain is configured using the services.cosmos.nodes namespace
4. **IBC Integration**: Hermes relayer is configured to enable cross-chain communication
5. **Contract Automation**: Smart contracts are automatically deployed to appropriate chains
6. **Genesis Configuration**: Account setup and other genesis parameters are easily configured

This approach demonstrates the power of zero.nix as a foundation for creating heterogeneous blockchain environments with minimal configuration overhead. 