{
  flake.modules.homeManager.vim =
    { config, ... }:
    {
      xdg.configFile."vim/vimrc".text = ''
        syntax on
        filetype plugin indent on
        set viminfofile=${config.xdg.stateHome}/vim/viminfo
        set mouse=a
      '';
      xdg.stateFile."vim/.keep".text = ""; # vim won't create the viminfo directory itself
    };
}
