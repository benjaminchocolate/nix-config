{
  imports = [ ../../modules/darwin ];

  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = "ben";
  users.users.ben.home = "/Users/ben";

  home-manager.users.ben.dotfiles.path = "/private/etc/nix-darwin";

  system.stateVersion = 7;
  home-manager.users.ben.home.stateVersion = "26.05";

  networking.hostName = "honeycrisp";
  networking.localHostName = "honeycrisp";
  networking.computerName = "Honeycrisp";
}
