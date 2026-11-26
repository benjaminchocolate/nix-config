{ inputs, config, ... }:
{
  flake.modules.darwin.honeycrisp = {
    imports = with inputs.self.modules.darwin; [
      ds-store-killer
      emacs
      environment
      home-manager
      login-items
      macos-defaults
      nix-homebrew
      nixpkgs
      packages
      shell
      system
    ];

    home-manager.users.ben = {
      imports = with inputs.self.modules.homeManager; [
        base
        direnv
        dotfiles
        dtui
        fastfetch
        ghostty
        git
        links
        mpv
        neovim
        secrets
        shell
        sparkle
        ssh
      ];

      dotfiles = {
        path = "/private/etc/nix-darwin";
        live = [
          "aerospace"
          "hammerspoon"
          "karabiner"
        ];
      };

      home.stateVersion = "26.05";
    };

    nixpkgs.hostPlatform = "aarch64-darwin";

    networking = {
      hostName = "honeycrisp";
      localHostName = "honeycrisp";
      computerName = "Honeycrisp";
    };

    system.primaryUser = "ben";
    users.users.ben.home = "/Users/ben";

    system.stateVersion = 7;
  };

  flake.darwinConfigurations.honeycrisp = inputs.nix-darwin.lib.darwinSystem {
    modules = [ config.flake.modules.darwin.honeycrisp ];
  };
}
