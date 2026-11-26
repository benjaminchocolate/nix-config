{
  # Host side of the dabinett VM: `dabinett build` makes the golden image from the
  # dabinett flake host, `dabinett` opens a throwaway clone, `dabinett reset` deletes it
  flake.modules.homeManager.tart =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      base = "ghcr.io/cirruslabs/macos-tahoe-base:latest";
      flake = "github:benjaminchocolate/nix-config#dabinett";
    in
    {
      home.sessionVariables.TART_HOME = "${config.xdg.dataHome}/tart";

      # VMs are tens of GB and change constantly; tmutil's exclusion is a sticky xattr, so rerunning is harmless
      home.activation.tartBackupExclusion = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "${config.xdg.dataHome}/tart"
        run /usr/bin/tmutil addexclusion "${config.xdg.dataHome}/tart"
      '';

      home.packages = [
        pkgs.tart
        (pkgs.writeShellApplication {
          name = "dabinett";
          runtimeInputs = [
            pkgs.gh
            pkgs.tart
          ];
          text = ''
            golden=dabinett
            work=dabinett-work

            exists() { tart get "$1" >/dev/null 2>&1; }

            # Boots headless and waits for the guest agent, which tart exec talks to
            start() {
              tart exec "$1" true 2>/dev/null && return
              nohup tart run --no-graphics "$1" >/dev/null 2>&1 &
              printf 'Waiting for %s...\n' "$1"
              until tart exec "$1" true 2>/dev/null; do sleep 2; done
            }

            # TODO(ben): log the VM into GitHub, then run brew-dev-setup.
            github_login() {
              :
            }

            build() {
              if exists "$golden"; then
                echo "$golden exists. To rebuild it: tart delete $golden" >&2
                exit 1
              fi
              tart clone ${base} "$golden"
              start "$golden"

              # The script arrives on stdin, so anything that might read stdin gets /dev/null
              tart exec -i "$golden" bash -s <<'PROVISION'
            set -eu
            nix=/nix/var/nix/profiles/default/bin/nix
            printf 'admin\n' | sudo -S sh -c \
              'echo "admin ALL=(ALL) NOPASSWD: ALL" >/etc/sudoers.d/admin-nopasswd'
            if [ ! -x "$nix" ]; then
              curl -fsSL https://install.determinate.systems/nix |
                sh -s -- install --no-confirm </dev/null
            fi
            for f in /etc/bashrc /etc/zshrc; do
              if [ -f "$f" ] && [ ! -L "$f" ]; then sudo mv "$f" "$f.before-nix-darwin"; fi
            done
            sudo "$nix" run github:nix-darwin/nix-darwin/master#darwin-rebuild -- \
              switch --flake ${flake} </dev/null
            PROVISION

              tart stop "$golden"
              echo "Built $golden. Run: dabinett"
            }

            shell() {
              exists "$golden" || { echo "No golden image yet. Run: dabinett build" >&2; exit 1; }
              exists "$work" || tart clone "$golden" "$work"
              start "$work"
              exec tart exec -it "$work" zsh -l
            }

            reset() {
              tart stop "$work" 2>/dev/null || true
              tart delete "$work"
            }

            case "''${1:-shell}" in
              build) build ;;
              shell) shell ;;
              reset) reset ;;
              *) echo "Usage: dabinett [build|shell|reset]" >&2; exit 1 ;;
            esac
          '';
        })
      ];
    };
}
