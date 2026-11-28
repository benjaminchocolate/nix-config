{ inputs, ... }:
{
  flake.modules.darwin.nix = {
    # Also turns off nix-darwin's own Nix management (nix.enable = false)
    imports = [ inputs.determinate.darwinModules.default ];

    # Written to /etc/nix/nix.custom.conf. No GC setting: Determinate Nixd collects
    # garbage on its own, and a second collector would fight it.
    determinateNix.customSettings.auto-optimise-store = true;

    nixpkgs.config.allowUnfree = true;
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; # shown by darwin-version
  };

  flake.modules.nixos.nix = {
    imports = [ inputs.determinate.nixosModules.default ];

    # Determinate Nixd handles GC here too
    nix.settings.auto-optimise-store = true;

    nixpkgs.config.allowUnfree = true;
  };
}
