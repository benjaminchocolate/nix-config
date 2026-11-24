{
  description = "My Nix flake for NixOS and nix-darwin, built on Determinate Nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-26.05";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    copyparty = {
      url = "github:9001/copyparty";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    ds-store-killer = {
      url = "github:kawayww/ds-store-killer";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixpkgs-stable,
      nix-darwin,
      git-hooks,
      ...
    }:
    let
      forSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    {
      formatter = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system: nixpkgs.legacyPackages.${system}.nixfmt-tree
      );

      checks = forSystems (system: {
        pre-commit = git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            gitleaks.enable = true;
            nixfmt.enable = true;
            readme = {
              enable = true;
              name = "update README";
              entry = nixpkgs.lib.getExe (
                nixpkgs.legacyPackages.${system}.callPackage ./pkgs/update-readme.nix { }
              );
              pass_filenames = false;
            };
            commit-msg-review = {
              enable = true;
              name = "review commit message";
              entry = nixpkgs.lib.getExe (
                nixpkgs.legacyPackages.${system}.callPackage ./pkgs/commit-msg-review.nix { }
              );
              stages = [ "commit-msg" ];
            };
          };
        };
      });

      devShells = forSystems (system: {
        default = nixpkgs.legacyPackages.${system}.mkShellNoCC {
          inherit (inputs.self.checks.${system}.pre-commit) shellHook;
          buildInputs = inputs.self.checks.${system}.pre-commit.enabledPackages;
        };
      });

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
