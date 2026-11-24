{ inputs, ... }:
{
  flake.nixosConfigurations.cosmic-crisp = inputs.nixpkgs-stable.lib.nixosSystem {
    specialArgs = { inherit inputs; };
    modules = [ ../../hosts/cosmic-crisp ];
  };
}
