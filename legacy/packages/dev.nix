{ pkgs, ... }:
{
  home.packages = with pkgs; [
    age
    gh
    gitleaks
    just
    mosh
    nixfmt
    rclone
    sequoia-sq
    shellcheck
    sops
  ];
}
