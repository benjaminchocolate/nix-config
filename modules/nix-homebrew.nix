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

      # Keep the Brewfile in sync with the taps declared in nix-homebrew.taps
      homebrew.taps = map (name: {
        inherit name;
        trusted = true;
      }) (builtins.attrNames config.nix-homebrew.taps);
    };
}
