# Git: identity, SSH commit signing, global ignores
{ config, ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      ".DS_Store"
      "*.swp"
      ".direnv/"
      "result"
    ];
    settings = {
      user = {
        name = "Benjamin Carpenter";
        email = "dev@benjamincarpenter.dev";
        signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
      init.defaultBranch = "main";
    };
  };
}
