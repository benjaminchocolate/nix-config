server := "root@104.204.70.197"
image := "ghcr.io/cirruslabs/macos-golden-gate-base:latest"

# Apply a host's config and keep it: just switch cosmic-crisp
switch host:
    @just _{{host}} switch

# Try a host's config without keeping it: just test honeycrisp
test host:
    @just _{{host}} test

# Go back to the previous generation: just rollback cosmic-crisp
rollback host:
    @just _{{host}} rollback

# Update flake.lock only. Nothing changes until you switch.
update:
    nix flake update

# Upgrade everything: Nix itself, flake inputs, Homebrew, both hosts
upgrade:
    sudo determinate-nixd upgrade
    nix flake update
    @just switch honeycrisp
    brew update
    brew upgrade --greedy
    applesauce compress /Applications >/dev/null
    @just switch cosmic-crisp

# The gala VM: just gala (shell in a throwaway clone) | build | update | reset
gala action="shell":
    #!/usr/bin/env bash
    set -euo pipefail
    up() { # tart exec only answers once the guest agent is up
      tart exec "$1" true 2>/dev/null && return
      nohup tart run --no-graphics "$1" >/dev/null 2>&1 &
      until tart exec "$1" true 2>/dev/null; do sleep 2; done
    }
    case {{action}} in
      build)
        tart pull {{image}}
        tart clone {{image}} gala
        up gala
        tart exec gala sh -c 'curl -fsSL https://raw.githubusercontent.com/benjaminchocolate/nix-config/main/bootstrap.sh | sh -s -- gala'
        tart stop gala ;;
      update)
        up gala
        tart exec gala zsh -lc 'git -C /etc/nix-darwin pull --ff-only && sudo darwin-rebuild switch --flake /etc/nix-darwin#gala'
        tart stop gala ;;
      shell)
        tart get gala-work >/dev/null 2>&1 || tart clone gala gala-work
        up gala-work
        exec tart exec -it gala-work zsh -l ;;
      reset)
        tart stop gala-work 2>/dev/null || true
        tart delete gala-work ;;
      *) echo "Usage: just gala [build|update|reset]" >&2; exit 1 ;;
    esac

# Check the Xcode Command Line Tools: path, version, pending update
clt:
    #!/usr/bin/env bash
    dir=$(xcode-select -p 2>/dev/null)
    if [[ -z $dir || ! -x $dir/usr/bin/git ]]; then
      echo "Broken or missing (${dir:-no developer path}). Run: just clt-fix"
      exit 1
    fi
    echo "Path:    $dir"
    echo "Version: $(pkgutil --pkg-info=com.apple.pkg.CLTools_Executables 2>/dev/null | awk '/^version/ {print $2}')"
    if softwareupdate --list 2>&1 | grep -q 'Label: Command Line Tools'; then
      echo "Update available. Run: just clt-fix"
    else
      echo "Up to date"
    fi

# Reinstall the newest Command Line Tools (fixes "invalid active developer path")
[confirm("Delete /Library/Developer/CommandLineTools and reinstall it?")]
clt-fix:
    #!/usr/bin/env bash
    set -euo pipefail
    marker=/tmp/.com.apple.dt.CommandLineTools.installondemand.in-progress
    touch "$marker" # makes Software Update offer the tools even when they're installed
    trap 'rm -f "$marker"' EXIT
    label=$(softwareupdate --list 2>/dev/null | awk -F': ' '/Label: Command Line Tools/ {print $2}' | sort -V | tail -1)
    if [[ -z $label ]]; then
      echo "Software Update offers no Command Line Tools. Try: xcode-select --install"
      exit 1
    fi
    echo "Installing $label"
    sudo rm -rf /Library/Developer/CommandLineTools
    sudo softwareupdate --install "$label"
    sudo xcode-select --reset

# macOS has no "test", so test only builds the config
_honeycrisp action:
    {{ if action == "test" { "darwin-rebuild build" } else if action == "rollback" { "sudo darwin-rebuild switch --rollback" } else { "sudo darwin-rebuild switch" } }} --flake .#honeycrisp

# Build only: switching here would turn this Mac into the VM. Use just gala update.
_gala action:
    {{ if action == "test" { "darwin-rebuild build --flake .#gala" } else { error("gala only supports test") } }}

_cosmic-crisp action:
    nix run nixpkgs#nixos-rebuild -- {{ if action == "rollback" { "switch --rollback" } else { action } }} --no-reexec --flake .#cosmic-crisp --target-host {{server}} --build-host {{server}}
