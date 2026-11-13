# Secrets with sops-nix.
#
# Secret values live encrypted in secrets/secrets.yaml, which is safe to
# commit. At login a small agent decrypts them with my age key into files
# only I can read. Nothing here does anything until a secret is declared.
#
# First-time setup and adding a secret: see "Secrets" in README.md.
{
  config,
  inputs,
  lib,
  ...
}:
let
  secretsFile = ../../secrets/secrets.yaml;
in
{
  imports = [ inputs.sops-nix.homeManagerModules.sops ];

  sops = {
    # The private key. It never goes in the repo; `just secrets-init` makes it.
    # A dedicated age key is used instead of ~/.ssh/id_ed25519 because
    # sops-nix cannot use an SSH key that has a passphrase.
    age.keyFile = "${config.xdg.configHome}/sops/age/keys.txt";

    # The file does not exist until `just secrets-init` has run, and a path
    # to a missing file would fail the build.
    defaultSopsFile = lib.mkIf (builtins.pathExists secretsFile) secretsFile;

    # Declare each secret that should be decrypted, by its key in the file:
    #
    #   secrets.github_token = { };
    #
    # It then appears as a file at config.sops.secrets.github_token.path
    # (~/.config/sops-nix/secrets/github_token). To use it in zsh:
    #
    #   export GITHUB_TOKEN="$(< ~/.config/sops-nix/secrets/github_token)"
  };
}
