{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    _0xproto
    atkinson-hyperlegible-mono
    atkinson-hyperlegible-next
    fira-code
    material-symbols
    nerd-fonts.symbols-only
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-monochrome-emoji
    powerline-symbols
    unifont
  ];
}
