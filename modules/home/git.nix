{ config, ... }:
{
  programs.git = {
    enable = true;
    ignores = [
      "*.swp"
      ".DS_Store"
      ".direnv/"
      "result"
    ];
    settings = {
      user = {
        name = "Benjamin Carpenter";
        email = "dev@benjamincarpenter.dev";
        signingkey = "${config.home.homeDirectory}/.ssh/id_ed25519.pub";
      };
      init.defaultBranch = "main";
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;
    };
  };
}
