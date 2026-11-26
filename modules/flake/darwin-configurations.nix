{ lib, ... }:
{
  # flake-parts only declares nixosConfigurations; without this, two darwin hosts can't merge
  options.flake.darwinConfigurations = lib.mkOption {
    type = lib.types.lazyAttrsOf lib.types.raw;
    default = { };
  };
}
