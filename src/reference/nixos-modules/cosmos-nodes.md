## services\.cosmos\.nodeDefaults

*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/options\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/options.nix)



## services\.cosmos\.nodeDefaults\.package



*Type:*
package

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.appSettings



settings to override in app\.toml



*Type:*
TOML value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.bech32-prefix



*Type:*
string



*Default:*
` "cosmos" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.chain-id



*Type:*
string

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.command



*Type:*
absolute path



*Default:*
` "\${config.package}/bin/\${config.package.meta.mainProgram}" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.contracts



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.contracts\.\<name>\.initialState



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.contracts\.\<name>\.path



*Type:*
absolute path

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.dataDir



*Type:*
absolute path



*Default:*
` "/var/lib/cosmos-node-<name>" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.ephemeral



Whether to enable destruction of nodes data on service stop
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.flags



command line flags to pass chain node command



*Type:*
attribute set of string



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisAccounts



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisAccounts\.\<name>\.amount



*Type:*
string



*Default:*
` "0" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisAccounts\.\<name>\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisAccounts\.\<name>\.mnemonic



*Type:*
string



*Default:*

```
''
  Automatically determined from list of mnemonic based on alphabetical order of all genesis accounts for this chain.
''
```

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisAccounts\.\<name>\.stakeAmount



*Type:*
string



*Default:*
` "0" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisSettings



settings to override in genesis\.json



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.genesisSubcommand



*Type:*
string



*Default:*
` "" `



*Example:*
` "genesis" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.isConsumer



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.minimum-gas-price



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.minimum-gas-price\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.minimum-gas-price\.price



*Type:*
floating point number



*Default:*
` 0.0 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.moniker



*Type:*
string



*Default:*
` "\${name}" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.settings



settings to override in config\.toml



*Type:*
TOML value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.transactions\.gas-multiplier



*Type:*
floating point number



*Default:*
` 1.5 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.transactions\.gas-price



*Type:*
submodule



*Default:*

```
{
  price = {
    _type = "override";
    content = 0.0;
    priority = 1000;
  };
}
```

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.transactions\.gas-price\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.transactions\.gas-price\.price



*Type:*
floating point number



*Default:*
` 0.0 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodeDefaults\.trusting-period



*Type:*
string



*Default:*
` "336h" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes



*Type:*
attribute set of (submodule)

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/options\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/options.nix)



## services\.cosmos\.nodes\.\<name>\.package



*Type:*
package

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.appSettings



settings to override in app\.toml



*Type:*
TOML value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.bech32-prefix



*Type:*
string



*Default:*
` "cosmos" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.chain-id



*Type:*
string

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.command



*Type:*
absolute path



*Default:*
` "\${config.package}/bin/\${config.package.meta.mainProgram}" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.contracts



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.contracts\.\<name>\.initialState



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.contracts\.\<name>\.path



*Type:*
absolute path

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.dataDir



*Type:*
absolute path



*Default:*
` "/var/lib/cosmos-node-‹name›" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.ephemeral



Whether to enable destruction of nodes data on service stop
\.



*Type:*
boolean



*Default:*
` false `



*Example:*
` true `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.flags



command line flags to pass chain node command



*Type:*
attribute set of string



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisAccounts



*Type:*
attribute set of (submodule)



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisAccounts\.\<name>\.amount



*Type:*
string



*Default:*
` "0" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisAccounts\.\<name>\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisAccounts\.\<name>\.mnemonic



*Type:*
string



*Default:*

```
''
  Automatically determined from list of mnemonic based on alphabetical order of all genesis accounts for this chain.
''
```

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisAccounts\.\<name>\.stakeAmount



*Type:*
string



*Default:*
` "0" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisSettings



settings to override in genesis\.json



*Type:*
JSON value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.genesisSubcommand



*Type:*
string



*Default:*
` "" `



*Example:*
` "genesis" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.isConsumer



*Type:*
boolean



*Default:*
` false `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.minimum-gas-price



*Type:*
submodule



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.minimum-gas-price\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.minimum-gas-price\.price



*Type:*
floating point number



*Default:*
` 0.0 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.moniker



*Type:*
string



*Default:*
` "\${name}" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.settings



settings to override in config\.toml



*Type:*
TOML value



*Default:*
` { } `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.transactions\.gas-multiplier



*Type:*
floating point number



*Default:*
` 1.5 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.transactions\.gas-price



*Type:*
submodule



*Default:*

```
{
  price = {
    _type = "override";
    content = 0.0;
    priority = 1000;
  };
}
```

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.transactions\.gas-price\.denom



*Type:*
string



*Default:*
` "stake" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.transactions\.gas-price\.price



*Type:*
floating point number



*Default:*
` 0.0 `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)



## services\.cosmos\.nodes\.\<name>\.trusting-period



*Type:*
string



*Default:*
` "336h" `

*Declared by:*
 - [/nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts\.nix](file:///nix/store/0a23qamphxj884mmgnbqx2jfanf6kymg-source/nixosModules/cosmos-node/node-opts.nix)


