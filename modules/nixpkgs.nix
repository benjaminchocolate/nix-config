let
  settings.nixpkgs.config.allowUnfree = true;
in
{
  flake.modules.darwin.nixpkgs = settings;
  flake.modules.nixos.nixpkgs = settings;
}
