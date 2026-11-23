{
  description = "My Determinate Nix-nix-darwin flake";

  inputs = {
    # Unstable Nixpkgs repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    # System configuration management
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # User configuration management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";

    ds-store-killer = {
      url = "github:kawayww/ds-store-killer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs-stable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    # inputs.nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-stable,
      nix-darwin,
      disko,
      determinate,
      ...
    }:
    {
      # `nix fmt` (and `just fmt`) formats every .nix file with nixfmt.
      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      # One entry per machine. The name must match the Mac's LocalHostName
      # (`scutil --get LocalHostName`) so `darwin-rebuild --flake .` finds it
      # without a `#name` suffix.
      darwinConfigurations."honeycrisp" = nix-darwin.lib.darwinSystem {
        # Hands `inputs` to every module as an argument: `{ inputs, ... }:`
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/honeycrisp ];
      };
      nixosConfigurations."cosmic-crisp" = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          disko.nixosModules.disko
          determinate.nixosModules.default
          ./hosts/cosmic-crisp/default.nix
          ./hosts/cosmic-crisp/hardware-configuration.nix
        ];
      };
    };
}
