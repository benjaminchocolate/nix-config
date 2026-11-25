# Live-editable configs: ~/.config/<name> links to config/<name> in this
# repo, so edits apply without a rebuild. Nix only owns the symlink.
{
  flake.modules.homeManager.dotfiles =
    { config, lib, ... }:
    let
      cfg = config.dotfiles;

      # mkOutOfStoreSymlink must be given a *string*. A path literal such as
      # ./config/emacs would be copied into the store first (flakes copy the
      # whole repo there), and the link would point at that frozen copy.
      link = relative: config.lib.file.mkOutOfStoreSymlink "${cfg.path}/${relative}";
    in
    {
      options.dotfiles = {
        path = lib.mkOption {
          type = lib.types.str;
          example = "/private/etc/nix-darwin";
          description = ''
            Absolute path of this repo's working tree on this machine.
            Set once per host; every live link is built from it.
          '';
        };

        live = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [ ];
          example = [ "emacs" ];
          description = ''
            Names of directories under config/. Each one is linked, as a whole
            directory, to ~/.config/<name>. Any module may add to the list.
          '';
        };
      };

      config = {
        assertions = [
          {
            assertion = lib.hasPrefix "/" cfg.path;
            message = "dotfiles.path must be an absolute path, got: ${cfg.path}";
          }
        ];

        # For the rare link that is not ~/.config/<name>:
        #   home.file."somewhere".source = config.lib.dotfiles.link "config/x";
        lib.dotfiles = { inherit link; };

        xdg.configFile = lib.genAttrs cfg.live (name: {
          source = link "config/${name}";
        });
      };
    };
}
