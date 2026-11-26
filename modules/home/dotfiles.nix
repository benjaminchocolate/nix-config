# ~/.config/<name> links to config/<name> in the repo: edits apply without a rebuild
{
  flake.modules.homeManager.dotfiles =
    { config, lib, ... }:
    let
      cfg = config.dotfiles;

      # Must be a string: a path like ./config/emacs is copied into the store,
      # and the link would point at that frozen copy
      link = relative: config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${relative}";
    in
    {
      options.dotfiles = {
        path = lib.mkOption {
          type = lib.types.str;
          example = "/private/etc/nix-darwin";
          description = "Absolute path of this repo's working tree on this host.";
        };

        live = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "emacs" ];
          description = "Directories under config/ to link to ~/.config/<name>.";
        };
      };

      config = {
        assertions = [
          {
            assertion = lib.hasPrefix "/" cfg.path;
            message = "dotfiles.path must be an absolute path, got: ${cfg.path}";
          }
        ];

        xdg.configFile = lib.genAttrs cfg.live (name: {
          source = link "config/${name}";
        });
      };
    };
}
