# ==============================================================
# SYSTEM (nix-darwin): entry point. Each file is one concern;
# drop a line here to turn that whole concern off.
# ==============================================================
{
  imports = [
    ./system.nix # Nix, security, system packages, PATH
    ./macos-defaults.nix # Dock, Finder, screenshots, per-app prefs
    ./environment.nix # variables for shells AND Dock-launched apps (XDG, PATH)
    ./login-items.nix # apps opened at login
    ./homebrew.nix # Homebrew itself, its taps, and the general package lists
    ./zsh.nix # where zsh looks for its config (the config is in config/zsh)
    ./emacs.nix # everything emacs-plus: tap, app, deps, config, daemon
    ./ds-store-killer.nix # background daemon that deletes .DS_Store files
    ./home-manager.nix # wires modules/home into the system build
  ];
}
