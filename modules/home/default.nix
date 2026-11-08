# ==============================================================
# USER (Home Manager): entry point for ben's dotfiles.
# Emacs-related user settings live in modules/darwin/emacs.nix.
# ==============================================================
{ pkgs, ... }:
{
  imports = [
    ./git.nix
    ./shell.nix
  ];

  home.stateVersion = "26.05";
  manual.manpages.enable = false;

  # ── XDG ───────────────────────────────────────────────────
  xdg.enable = true;
  home.preferXdgDirectories = true;

  # ── Packages ──────────────────────────────────────────────
  home.packages = with pkgs; [
    #bun
    #zsh-completions
  ];

  # ── Dotfiles ──────────────────────────────────────────────
  home.file.".clang-format".text = ''
    BasedOnStyle: Google
  '';
  # BreakBeforeBraces: Allman
}
