{ config, ... }:
let
  link = config.lib.file.mkOutOfStoreSymlink;
in
{
  home.file."Developer/dotfiles".source = link config.dotfiles.path;
  home.file."Developer/container".source =
    link "${config.home.homeDirectory}/Library/Application Support/com.apple.container";
}
