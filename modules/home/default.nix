{
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./dotfiles.nix
    ./git.nix
    ./secrets.nix
    ./ssh.nix
    ./sparkle.nix
    ./links.nix
    ./infat.nix
    ./mpv.nix
    ./zsh.nix
    ./ghostty.nix
  ];

  dotfiles.live =
    [ ]
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      "aerospace"
      "hammerspoon"
      "karabiner"
    ];

  manual.manpages.enable = true; # Just want to see

  xdg.enable = true;
  home.preferXdgDirectories = true;

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs; [
    # bun
  ];

  xdg.configFile."vim/vimrc".text = ''
    syntax on
    filetype plugin indent on
    set viminfofile=${config.xdg.stateHome}/vim/viminfo
    set mouse=a
  '';
  xdg.stateFile."vim/.keep".text = ""; # Get rid of this?

  home.file.".hushlogin".text = "";

  home.file.".clang-format".text = ''
    BasedOnStyle: Google
  '';
}
