{
  imports = [
    ./environment.nix
    ./login-items.nix
    ./macos-defaults.nix
    ./system.nix
    ./zsh.nix

    ./ds-store-killer.nix
    ./emacs.nix
    ../packages/homebrew.nix

    ./home-manager.nix
  ];
}
