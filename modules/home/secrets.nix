{ inputs, ... }:
# Home Manager secrets: encrypted in secrets/secrets.yaml, decrypted at login.
# The file needs a creation rule in .sops.yaml before `sops` can create it.
{
  flake.modules.homeManager.secrets =
    { config, lib, ... }:
    let
      secretsFile = ../../secrets/secrets.yaml;
    in
    {
      imports = [ inputs.sops-nix.homeManagerModules.sops ];

      sops = {
        # Not ~/.ssh/id_ed25519: sops-nix can't use a key with a passphrase.
        age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

        # A path to a missing file fails the build.
        defaultSopsFile = lib.mkIf (builtins.pathExists secretsFile) secretsFile;

        # Declare secrets here, e.g. `secrets.github_token = { };`, then read
        # config.sops.secrets.github_token.path.
      };
    };
}
