{ inputs, ... }:
{
  imports = [ inputs.git-hooks.flakeModule ];

  perSystem =
    { config, pkgs, ... }:
    {
      formatter = pkgs.nixfmt-tree;

      pre-commit.settings.hooks = {
        gitleaks.enable = true;
        nixfmt.enable = true;
        readme = {
          enable = true;
          name = "update README";
          entry = pkgs.lib.getExe (pkgs.callPackage ../pkgs/update-readme.nix { });
          pass_filenames = false;
        };
        commit-msg-review = {
          enable = true;
          name = "review commit message";
          entry = pkgs.lib.getExe (pkgs.callPackage ../pkgs/commit-msg-review.nix { });
          stages = [ "commit-msg" ];
        };
      };

      devShells.default = pkgs.mkShellNoCC {
        inherit (config.pre-commit) shellHook;
        packages = config.pre-commit.settings.enabledPackages;
      };
    };
}
