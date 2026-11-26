{ inputs, ... }:
{
  flake.modules.darwin.nix-homebrew =
    { config, ... }:
    {
      imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

      nix-homebrew = {
        enable = true;
        user = config.system.primaryUser;
        autoMigrate = true;
      };

      # Brewfile taps come from nix-homebrew.taps, so a tap is only declared once
      homebrew.taps = map (name: {
        inherit name;
        trusted = true;
      }) (builtins.attrNames config.nix-homebrew.taps);
    };
}
