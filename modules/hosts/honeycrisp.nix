{ inputs, config, ... }:
{
  flake.modules.darwin.honeycrisp = {
    imports = [
      ../../legacy/darwin
      inputs.self.modules.darwin.packages
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
        secrets
        shell
        sparkle
        ssh
        vim
      ];

      dotfiles.live = [
        "aerospace"
        "hammerspoon"
        "karabiner"
      ];
    };

    nixpkgs.hostPlatform = "aarch64-darwin";

    networking = {
      hostName = "honeycrisp";
      localHostName = "honeycrisp";
      computerName = "Honeycrisp";
    };

    system.primaryUser = "ben";
    users.users.ben.home = "/Users/ben";
    home-manager.users.ben.dotfiles.path = "/private/etc/nix-darwin";

    system.stateVersion = 7;
    home-manager.users.ben.home.stateVersion = "26.05";
  };

  flake.darwinConfigurations.honeycrisp = inputs.nix-darwin.lib.darwinSystem {
    specialArgs = { inherit inputs; }; # legacy modules take inputs
    modules = [ config.flake.modules.darwin.honeycrisp ];
  };
}
