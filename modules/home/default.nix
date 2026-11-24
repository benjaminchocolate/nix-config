# ==============================================================
# USER (Home Manager): entry point for ben's dotfiles.
# Emacs-related user settings live in modules/darwin/emacs.nix.
# zsh is not here on purpose: its config is plain files in config/zsh.
# ==============================================================
{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dotfiles.nix # the live-link mechanism used below
    ./git.nix
    ./secrets.nix
    ./ssh.nix
    ./sparkle.nix
    ./links.nix
    ./infat.nix
    ./mpv.nix
    ./zsh.nix
  ];

  # ── Live-editable configs ─────────────────────────────────
  # Each name is a directory in config/ linked to ~/.config/<name>.
  # Editing those files needs no rebuild; adding a name here does.
  # (Emacs adds itself in modules/darwin/emacs.nix.)
  dotfiles.live = [

  ]
  ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "aerospace"
    "hammerspoon"
    "karabiner"
  ];

  manual.manpages.enable = false;

  # ── XDG ───────────────────────────────────────────────────
  xdg.enable = true;
  home.preferXdgDirectories = true;

  # ── direnv ────────────────────────────────────────────────
  # Loads a project's .envrc when you cd into it. With nix-direnv, a line
  # `use flake` in .envrc gives that directory its flake's dev shell, cached
  # so it is instant after the first time. The zsh hook is in config/zsh/.zshrc.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # ── Packages ──────────────────────────────────────────────
  home.packages = with pkgs; [
    #bun
    #zsh-completions
  ];

  # ── Dotfiles small enough to keep inline ──────────────────
  # Vim: XDG config location is built in; the viminfo location is not.
  xdg.configFile."vim/vimrc".text = ''
    syntax on
    filetype plugin indent on
    set viminfofile=${config.xdg.stateHome}/vim/viminfo
  '';
  xdg.stateFile."vim/.keep".text = ""; # vim won't create the directory itself

  # Skip the "Last login: ..." line in new terminals. Has to be in ~.
  home.file.".hushlogin".text = "";

  home.file.".clang-format".text = ''
    BasedOnStyle: Google
  '';
  # BreakBeforeBraces: Allman
}
