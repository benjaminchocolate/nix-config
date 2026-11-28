{ inputs, config, ... }:
{
  # Tart VM for Homebrew contributions (`just gala`). "admin" is the Cirrus image's user.
  flake.modules.darwin.gala = {
    imports = with inputs.self.modules.darwin; [
      home-manager
      homebrew-dev
      nix
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
      hostName = "gala";
      localHostName = "gala";
      computerName = "Gala";
    };

    nixpkgs.hostPlatform = "aarch64-darwin";
    system.primaryUser = "admin";
    users.users.admin.home = "/Users/admin";
    system.stateVersion = 7;
  };

  flake.darwinConfigurations.gala = inputs.nix-darwin.lib.darwinSystem {
    modules = [ config.flake.modules.darwin.gala ];
  };
}
