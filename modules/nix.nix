{ inputs, ... }:
{
  flake.modules.darwin.nix = {
    nix.enable = false; # Determinate Nix manages the daemon
    nixpkgs.config.allowUnfree = true;
    system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null; # shown by darwin-version
  };

  flake.modules.nixos.nix = {
    imports = [ inputs.determinate.nixosModules.default ];
    nixpkgs.config.allowUnfree = true;
  };
}
