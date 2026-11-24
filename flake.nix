{
  description = "My Nix flake for NixOS and nix-darwin, built on Determinate Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ds-store-killer = {
      url = "github:kawayww/ds-store-killer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
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
      formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      darwinConfigurations."honeycrisp" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/honeycrisp ];
      };

      nixosConfigurations."cosmic-crisp" = nixpkgs-stable.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [ ./hosts/cosmic-crisp ];
      };
    };
}
