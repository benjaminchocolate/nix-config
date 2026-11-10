{ config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file."Developer/dotfiles".source = link "/private/etc/nix-darwin";
  home.file."Developer/homebrew-tap".source =
    link "/opt/homebrew/Library/Taps/benjaminchocolate/homebrew-tap";
  home.file."Developer/container".source =
    link "/Users/ben/Library/Application Support/com.apple.container";
}
