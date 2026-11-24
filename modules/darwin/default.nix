{
  imports = [
    ./system.nix
    ./macos-defaults.nix
    ./environment.nix
    ./login-items.nix
    ../packages/homebrew.nix
    ./zsh.nix
    ./emacs.nix
    ./ds-store-killer.nix
    ./home-manager.nix
  ];
}
