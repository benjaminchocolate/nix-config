server := "root@104.204.70.197"

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
    brew update
    brew upgrade --greedy
    @just switch honeycrisp
    @just switch cosmic-crisp

# macOS has no "test", so test only builds the config
_honeycrisp action:
    {{ if action == "test" { "darwin-rebuild build" } else if action == "rollback" { "sudo darwin-rebuild switch --rollback" } else { "sudo darwin-rebuild switch" } }} --flake .#honeycrisp

_cosmic-crisp action:
    nix run nixpkgs#nixos-rebuild -- {{ if action == "rollback" { "switch --rollback" } else { action } }} --no-reexec --flake .#cosmic-crisp --target-host {{server}} --build-host {{server}}
