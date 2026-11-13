# Home Manager, run as part of the system build (one `switch` does both).
{ config, inputs, ... }:
{
  imports = [ inputs.home-manager.darwinModules.home-manager ];

  home-manager = {
    useGlobalPkgs = true; # reuse the system's nixpkgs instead of a second copy
    useUserPackages = true; # install to /etc/profiles/per-user/<name>
    # If a file Home Manager wants to manage already exists, move it to
    # <name>.backup instead of aborting the switch.
    backupFileExtension = "backup";
    # Same as specialArgs in flake.nix, for Home Manager modules.
    extraSpecialArgs = { inherit inputs; };

    users.${config.system.primaryUser}.imports = [ ../home ]; # modules/home/default.nix
  };
}
