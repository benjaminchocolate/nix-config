# Machine basics: Nix, security, system packages, PATH
{
  config,
  pkgs,
  inputs,
  ...
}:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  # ── Nix ───────────────────────────────────────────────────
  nix.enable = false; # Determinate Nix manages the Nix daemon

  # Necessary for using flakes on this system.
  #nix.settings.experimental-features = "nix-command flakes";

  # Set Git commit hash for darwin-version.
  # (`self` lives in `inputs`, passed in via specialArgs in flake.nix)
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # ── Shells ────────────────────────────────────────────────
  # Enable alternative shell support in nix-darwin.
  # programs.fish.enable = true;

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
    "${home}/.local/bin" # user-installed binaries (the XDG convention)
  ];
}
