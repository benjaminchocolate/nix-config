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

    # Homebrew management
    # NOTE: nix-homebrew and the two tap inputs below are fetched but never
    # added to `modules`, so right now they do nothing.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      sops-nix,
    }:
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Benjamins-MacBook-Pro
      darwinConfigurations."Benjamins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        # Hands `inputs` to every darwin module as an argument,
        # e.g. `{ inputs, ... }:` in modules/darwin/system.nix
        specialArgs = { inherit inputs; };

        modules = [
          ./modules/darwin # loads modules/darwin/default.nix
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ben = ./modules/home; # loads modules/home/default.nix
          }
        ];
      };
    };
}
