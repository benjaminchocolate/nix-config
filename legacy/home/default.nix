{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dotfiles.nix
    ./secrets.nix

    ./fastfetch.nix
    ./ghostty.nix
    ./git.nix
    ./mpv.nix
    ./ssh.nix
    ./zsh.nix

    ./dtui.nix
    ./links.nix
    ./sparkle.nix

    ../packages/cli.nix
    ../packages/dev.nix
    ../packages/fonts.nix
    ../packages/media.nix
  ];

  xdg.enable = true;
  home.preferXdgDirectories = true;

  dotfiles.live = lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    "aerospace"
    "hammerspoon"
    "karabiner"
  ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  xdg.configFile."vim/vimrc".text = ''
    syntax on
    filetype plugin indent on
    set viminfofile=${config.xdg.stateHome}/vim/viminfo
    set mouse=a
  '';
  xdg.stateFile."vim/.keep".text = ""; # vim won't create the viminfo directory itself

  home.file.".hushlogin".text = "";
  home.file.".clang-format".text = ''
    BasedOnStyle: Google
  '';
}
