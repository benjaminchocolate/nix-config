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

      # Only my own tap is trusted whole. Casks from other taps must be written
      # user/tap/name: nix-darwin trusts each one on its own, and brew skips a bare name.
      homebrew.taps = map (name: {
        inherit name;
        trusted = name == "benjaminchocolate/homebrew-tap";
      }) (builtins.attrNames config.nix-homebrew.taps);
    };
}
