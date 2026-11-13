# Live-editable configs.
#
# Most of Home Manager copies files into the read-only Nix store, so changing
# them needs a rebuild. For configs I edit often (Emacs, zsh, Hammerspoon,
# Karabiner) that is the wrong trade. Instead the real files stay in this
# repo under config/, and ~/.config/<name> is a symlink to them:
#
#   ~/.config/emacs -> <repo>/config/emacs
#
# Edit the file, the program sees it. Nix only owns the symlink.
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
}
