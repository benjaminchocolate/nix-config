{ config, inputs, ... }:
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup"; # move conflicting files aside instead of failing
    extraSpecialArgs = { inherit inputs; };
  };
}
