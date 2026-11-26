{ lib, ... }:
{
  # flake-parts declares nixosConfigurations but not darwinConfigurations, so hosts in separate files can't merge without this
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
}
