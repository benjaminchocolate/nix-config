{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {
        AddKeysToAgent = "yes";
        IgnoreUnknown = "UseKeychain"; # only Apple's ssh knows UseKeychain
        UseKeychain = "yes";
      };
      "cosmic-crisp" = {
        HostName = "carpenterlab.dev";
        User = "root";
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
      };
      "github.com" = {
        IdentityFile = "~/.ssh/id_ed25519";
        IdentitiesOnly = "yes";
      };
    };
  };
}
