# Tasks for this repo. Inside the repo: `just <recipe>`.
# From anywhere: `dots <recipe>` (an alias defined in config/zsh/.zshrc).
#
# Bootstrap note: `just` itself is installed by this config, so the very
# first build on a new Mac is done by hand. See README.md.

flake := justfile_directory()
# darwinConfigurations.<name> in flake.nix is named after this.
host := `scutil --get LocalHostName`

# Show this list
default:
    @just --justfile "{{ justfile() }}" --list --unsorted

# ── Everyday ───────────────────────────────────────────────

# Build and activate the system (what the old `rebuild` alias did)
switch:
    sudo darwin-rebuild switch --flake "{{ flake }}#{{ host }}"

# Build without activating. No sudo; leaves ./result
build:
    darwin-rebuild build --flake "{{ flake }}#{{ host }}"

# Build, then list package changes against the running system
diff: build
    nix store diff-closures /run/current-system "{{ flake }}/result"

# Evaluate the whole system config (options, types, assertions) without building
check:
    nix eval --raw "{{ flake }}#darwinConfigurations.{{ host }}.system.drvPath"
    @echo
    nix flake check "{{ flake }}"

# Go back to the previous system generation
rollback:
    sudo darwin-rebuild --rollback

# ── Updating ───────────────────────────────────────────────
# Updates only change flake.lock. Nothing on the Mac changes until `switch`.

# Update every input, or only the named ones: `just update nixpkgs`
update *inputs:
    nix flake update {{ inputs }} --flake "{{ flake }}"

# Update the Homebrew taps only. This replaces `brew update`.
update-brew:
    nix flake update --flake "{{ flake }}" \
        homebrew-core homebrew-cask homebrew-emacs-plus \
        homebrew-tap homebrew-mattt homebrew-nikitabobko homebrew-y3owk1n

# Activate using a local clone of my tap, to test a cask before pushing it
switch-local-tap tap=(env("HOME") / "Developer/homebrew-tap"):
    sudo darwin-rebuild switch --flake "{{ flake }}#{{ host }}" \
        --override-input homebrew-tap "path:{{ tap }}"

# ── Secrets (sops + age) ───────────────────────────────────

age_key := env("HOME") / ".config/sops/age/keys.txt"

# One-time: create my age key and an empty encrypted secrets file
secrets-init:
    #!/bin/bash
    set -euo pipefail
    cd "{{ flake }}"
    if [ ! -f "{{ age_key }}" ]; then
        mkdir -p "$(dirname "{{ age_key }}")"
        age-keygen -o "{{ age_key }}"
        chmod 600 "{{ age_key }}"
    fi
    public_key="$(age-keygen -y "{{ age_key }}")"
    if [ ! -f .sops.yaml ]; then
        printf 'creation_rules:\n  - path_regex: secrets/.*\\.yaml$\n    age: %s\n' "$public_key" > .sops.yaml
    fi
    if [ ! -f secrets/secrets.yaml ]; then
        printf 'example: replace-me\n' > secrets/secrets.yaml
        sops --encrypt --in-place secrets/secrets.yaml
    fi
    git add .sops.yaml secrets/secrets.yaml
    echo "Key:     {{ age_key }}  (back this up somewhere safe; it is not in the repo)"
    echo "Public:  $public_key"
    echo "Next:    just secrets-edit"

# Open the decrypted secrets in $EDITOR; they are re-encrypted on save
secrets-edit:
    cd "{{ flake }}" && SOPS_AGE_KEY_FILE="{{ age_key }}" sops secrets/secrets.yaml

# ── Housekeeping ───────────────────────────────────────────

# Format every .nix file
fmt:
    cd "{{ flake }}" && nix fmt

# Look for common Nix mistakes and unused code
lint:
    nix run nixpkgs#statix -- check "{{ flake }}"
    nix run nixpkgs#deadnix -- "{{ flake }}"

# One-time move of old dotfiles to XDG locations. Dry run unless given --apply
migrate-xdg *args:
    bash "{{ flake }}/scripts/migrate-xdg.sh" {{ args }}

# Delete system generations and store paths older than DAYS days
gc days="14":
    sudo nix-collect-garbage --delete-older-than {{ days }}d
    nix-collect-garbage --delete-older-than {{ days }}d
