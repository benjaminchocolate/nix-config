{ inputs, ... }:
{
  # Gaming PC, not installed yet. Add facter.json and disk.nix like cosmic-crisp,
  # then a flake.nixosConfigurations.sunflare output.
  flake.modules.nixos.sunflare = {
    imports = with inputs.self.modules.nixos; [
      neovim
      nix
    ];

    networking.hostName = "sunflare";
    system.stateVersion = "26.05";
  };
}
