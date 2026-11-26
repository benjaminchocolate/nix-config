{ inputs, config, ... }:
{
  # Tart VM for Homebrew contributions, named for a cider apple; the user is Cirrus' default "admin"
  flake.modules.darwin.dabinett = {
    imports = with inputs.self.modules.darwin; [
      home-manager
      homebrew-dev
      nixpkgs
      shell
    ];

    home-manager.users.admin =
      { lib, ... }:
      {
        imports = with inputs.self.modules.homeManager; [
          base
          git
          neovim
          shell
        ];

        # No signing key inside the VM
        programs.git.settings = {
          commit.gpgsign = lib.mkForce false;
          tag.gpgsign = lib.mkForce false;
        };

        home.stateVersion = "26.05";
      };

    networking = {
      hostName = "dabinett";
      localHostName = "dabinett";
      computerName = "Dabinett";
    };

    nix.enable = false; # Determinate Nix manages the daemon
    nixpkgs.hostPlatform = "aarch64-darwin";
    system.primaryUser = "admin";
    users.users.admin.home = "/Users/admin";
    system.stateVersion = 7;
  };

  flake.darwinConfigurations.dabinett = inputs.nix-darwin.lib.darwinSystem {
    modules = [ config.flake.modules.darwin.dabinett ];
  };
}
