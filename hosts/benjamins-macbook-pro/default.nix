# Benjamins-MacBook-Pro (M5 MacBook Pro).
#
# A host file holds only what is true for this one machine: its platform,
# its user, and its state versions. Everything a second Mac would share lives
# in modules/darwin (system) and modules/home (Home Manager).
{
  imports = [ ../../modules/darwin ];

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  # ── User ──────────────────────────────────────────────────
  # nix-darwin runs user-level steps (Homebrew, defaults, launchd agents)
  # as this user. Modules read it as `config.system.primaryUser` instead of
  # spelling the name out.
  system.primaryUser = "ben";
  users.users.ben.home = "/Users/ben";

  # ── Where this repo lives ─────────────────────────────────
  # Live-editable configs are symlinks into this working tree
  # (modules/home/dotfiles.nix). /etc/nix-darwin is where darwin-rebuild
  # looks by default; ~/Developer/dotfiles is a convenience link to it.
  home-manager.users.ben.dotfiles.path = "/private/etc/nix-darwin";

  # ── State versions ────────────────────────────────────────
  # These record which release's defaults this machine started on. They are
  # not "the version I run": leave them alone when updating inputs.
  # $ darwin-rebuild changelog
  system.stateVersion = 6;
  home-manager.users.ben.home.stateVersion = "26.05";
}
