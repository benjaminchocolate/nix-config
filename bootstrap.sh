#!/usr/bin/env sh
# New Mac: curl -fsSL https://raw.githubusercontent.com/benjaminchocolate/nix-config/main/bootstrap.sh | sh
# Other host: ... | sh -s -- <host>
set -eu
host="${1:-honeycrisp}"
dest=/etc/nix-darwin
nix=/nix/var/nix/profiles/default/bin/nix

# 1. Determinate Nix
if [ ! -x "$nix" ]; then
  curl -fsSL https://install.determinate.systems/nix | sh -s -- install --no-confirm
fi

# 2. This repo (over HTTPS: there's no SSH key yet)
if [ ! -d "$dest/.git" ]; then
  sudo mkdir -p "$dest"
  sudo chown "$(id -un):staff" "$dest"
  "$nix" run nixpkgs#git -- clone https://github.com/benjaminchocolate/nix-config.git "$dest"
fi

# 3. nix-darwin refuses to overwrite shell files it didn't create
for f in /etc/bashrc /etc/zshrc; do
  if [ -f "$f" ] && [ ! -L "$f" ]; then sudo mv "$f" "$f.before-nix-darwin"; fi
done

# 4. Xcode Command Line Tools: Homebrew needs them, Nix doesn't
if ! xcode-select -p >/dev/null 2>&1; then
  xcode-select --install
  printf 'Finish installing the Command Line Tools, then press Enter... '
  read -r _ < /dev/tty
fi

# 5. masApps fail if the App Store is signed out
open -a "App Store"
printf 'Sign in to the App Store, then press Enter... '
read -r _ < /dev/tty

# 6. Apple's on-device model (commit message review); the license prompt is interactive
if command -v fm >/dev/null 2>&1; then
  fm license --status 2>/dev/null | grep -q Agreed || sudo fm license < /dev/tty
fi

# 7. First switch: installs Homebrew, apps, shell, dotfiles
sudo "$nix" run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake "$dest#$host"

cat <<'DONE'

Done. Still manual:
  - Restore ~/.ssh/id_ed25519 and ~/.config/sops/age/keys.txt from your password manager
  - git -C /etc/nix-darwin remote set-url origin git@github.com:benjaminchocolate/nix-config.git
  - Approve the Karabiner and BlackHole drivers in System Settings > Privacy & Security
  - Turn on Apple Intelligence if commit message review should work
DONE
