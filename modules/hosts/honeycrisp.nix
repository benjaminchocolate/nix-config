{ inputs, ... }:
{
  flake.darwinConfigurations.honeycrisp = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; };
    modules = [ ../../hosts/honeycrisp ];
  };
}
