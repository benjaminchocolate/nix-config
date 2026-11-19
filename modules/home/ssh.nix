{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings."*" = {
      AddKeysToAgent = "yes";
      IgnoreUnknown = "UseKeychain";
      UseKeychain = "yes";
    };
    settings."github.com" = {
      IdentityFile = "~/.ssh/id_ed25519";
      IdentitiesOnly = "yes";
    };
  };

}
