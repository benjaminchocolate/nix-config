{ inputs, ... }:
{
  flake.modules.darwin.nix-homebrew =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        user = config.system.primaryUser;
        autoMigrate = true; # take over the existing /opt/homebrew install
      };
    };
}
