#!/usr/bin/env python
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

# 4. masApps fail if the App Store is signed out
open -a "App Store"
printf 'Sign in to the App Store, then press Enter... '
read -r _ < /dev/tty

# 5. First switch: installs Homebrew, apps, shell, dotfiles
sudo "$nix" run github:nix-darwin/nix-darwin/master#darwin-rebuild -- switch --flake "$dest#$host"
