# Purpose: Override neutron package with Darwin support when on macOS
{ self, inputs, ... }:
{
  perSystem = { pkgs, config, lib, system, ... }: {
    # Override cosmos-nix neutron package with our Darwin-enabled version on macOS
    _module.args = {
      cosmos-nix-overrides = lib.optionalAttrs pkgs.stdenv.isDarwin {
        neutron = config.packages.neutrond;
      };
    };
  };
}