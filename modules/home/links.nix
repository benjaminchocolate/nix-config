{
  flake.modules.homeManager.links =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      link = config.lib.file.mkOutOfStoreSymlink;
    in
    {
      home.file = {
        "Developer/nix-config".source = link config.dotfiles.path;
      }
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isDarwin {
        "Developer/container".source =
          link "${config.home.homeDirectory}/Library/Application Support/com.apple.container";
        "Developer/homebrew-tap".source = link "/opt/homebrew/Library/Taps/benjaminchocolate/homebrew-tap";
      };
    };
}
