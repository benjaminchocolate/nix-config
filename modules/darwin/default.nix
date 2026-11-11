# ==============================================================
# SYSTEM (nix-darwin): entry point. Each file is one concern;
# drop a line here to turn that whole concern off.
# ==============================================================
{
  imports = [
    ./system.nix # Nix, platform, user, security, packages, PATH
    ./macos-defaults.nix # Dock, Finder, screenshots, per-app prefs
    ./launchd.nix # login items, session env vars, root daemons
    ./homebrew.nix # Homebrew settings and the general package lists
    ./emacs.nix # everything emacs-plus: tap, app, deps, config, daemon
    ./ds-store-killer.nix
  ];
}
