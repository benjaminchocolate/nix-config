{ pkgs, ... }:
{
  home.packages = with pkgs; [
    aria2
    bat
    cheat
    eza
    fastfetch
    fd
    navi
    ripgrep
    tlrc
    tree
    wget
    zoxide
  ];
}
