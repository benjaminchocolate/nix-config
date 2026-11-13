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

    # Homebrew itself, installed and pinned by Nix
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Homebrew taps, pinned as plain source trees (`flake = false`).
    # With `nix-homebrew.mutableTaps = false` these are the only taps brew can
    # see, so a package updates only when its tap input is bumped here
    # (`just update-brew`). modules/darwin/homebrew.nix maps them to tap names.
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-emacs-plus = {
      url = "github:d12frosted/homebrew-emacs-plus";
      flake = false;
    };
    # My own tap (custom casks)
    homebrew-tap = {
      url = "github:benjaminchocolate/homebrew-tap";
      flake = false;
    };
    # Third-party taps I use one cask from each
    homebrew-mattt = {
      url = "github:mattt/homebrew-tap"; # iMCP
      flake = false;
    };
    homebrew-nikitabobko = {
      url = "github:nikitabobko/homebrew-tap"; # AeroSpace
      flake = false;
    };
    homebrew-y3owk1n = {
      url = "github:y3owk1n/homebrew-tap"; # Neru
      flake = false;
    };

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
