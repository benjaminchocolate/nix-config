{
  # Official Homebrew, not nix-homebrew: contributing needs a mutable brew and taps
  flake.modules.darwin.homebrew-dev =
    { pkgs, ... }:
    {
      environment.systemPath = [ "/opt/homebrew/bin" ];
      environment.variables.HOMEBREW_DEVELOPER = "1";

      environment.systemPackages = [
        pkgs.gh
        (pkgs.writeShellApplication {
          name = "brew-dev-setup";
          runtimeInputs = [
            pkgs.gh
            pkgs.git
          ];
          text = ''
            # Usage: brew-dev-setup [cask] [core]   (default: cask)
            taps=("$@")
            [ ''${#taps[@]} -gt 0 ] || taps=(cask)

            gh auth status >/dev/null 2>&1 || gh auth login
            gh auth setup-git
            user=$(gh api user --jq .login)

            for tap in "''${taps[@]}"; do
              brew tap --force "homebrew/$tap"
              dir=$(brew --repository "homebrew/$tap")
              gh repo fork "Homebrew/homebrew-$tap" --clone=false --remote=false || true
              git -C "$dir" remote get-url "$user" >/dev/null 2>&1 ||
                git -C "$dir" remote add "$user" "https://github.com/$user/homebrew-$tap.git"
              echo "homebrew/$tap: $dir (remote: $user)"
            done
          '';
        })
      ];
    };
}
