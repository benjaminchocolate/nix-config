{
  description = "My Determinate Nix-nix-darwin flake";

  inputs = {
    # Unstable Nixpkgs repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

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
  };

  outputs =
    inputs@{ nixpkgs, nix-darwin, ... }:
    {
      # `nix fmt` (and `just fmt`) formats every .nix file with nixfmt.
      formatter = nixpkgs.lib.genAttrs [ "aarch64-darwin" "aarch64-linux" "x86_64-linux" ] (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      # One entry per machine. The name must match the Mac's LocalHostName
      # (`scutil --get LocalHostName`) so `darwin-rebuild --flake .` finds it
      # without a `#name` suffix.
      darwinConfigurations."Benjamins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        # Hands `inputs` to every module as an argument: `{ inputs, ... }:`
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/benjamins-macbook-pro ];
      };
    };
}
