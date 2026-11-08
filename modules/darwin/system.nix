# Machine basics: Nix, platform, user, security, system packages, PATH
{ pkgs, inputs, ... }:
{
  # ── Nix & platform ────────────────────────────────────────
  nix.enable = false; # Determinate Nix manages the Nix daemon

  # Necessary for using flakes on this system.
  #nix.settings.experimental-features = "nix-command flakes";

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Set Git commit hash for darwin-version.
  # (`self` lives in `inputs`, passed in via specialArgs in flake.nix)
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;

  # ── User & shells ─────────────────────────────────────────
  system.primaryUser = "ben";
  users.users.ben.home = "/Users/ben";

  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

  # TODO(ben): stop nix-darwin from writing compinit and bashcompinit into
  # /etc/zshrc. Home Manager's completionInit (modules/home/shell.nix) should
  # be the only compinit.

  # ── Security ──────────────────────────────────────────────
  security.pam.services.sudo_local.touchIdAuth = true;

  networking.applicationFirewall = {
    enable = true;
    enableStealthMode = true;
    allowSigned = false;
    allowSignedApp = false;
    blockAllIncoming = false; # must stay off, or the allowlist is ignored
  };

  # ── Nix packages & fonts ──────────────────────────────────
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    nixd
  ];

  # Fonts are installed as Homebrew casks (see "Fonts" in homebrew.nix).
  # Nixpkgs equivalents, kept for reference:
  fonts.packages = [
  ];

  # ── PATH ──────────────────────────────────────────────────
  environment.systemPath = [
    "/opt/homebrew/bin"
    "/Library/TeX/texbin"
    "/Users/ben/.local/bin/env"
  ];
}
