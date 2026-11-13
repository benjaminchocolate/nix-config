{ config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file."Developer/dotfiles".source = link config.dotfiles.path;
  # ~/Developer/homebrew-tap used to link into /opt/homebrew/Library/Taps.
  # Taps are read-only store paths now, so it is a normal clone instead.
  home.file."Developer/container".source =
    link "${config.home.homeDirectory}/Library/Application Support/com.apple.container";
}
