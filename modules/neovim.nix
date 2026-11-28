{
  flake.modules.homeManager.neovim = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      withPython3 = false;
      withRuby = false;
      initLua = "vim.o.termguicolors = false"; # use the terminal's colours, not Neovim's own theme
    };

    # Editing secrets: no swap file, no saved history or registers
    home.sessionVariables.SOPS_EDITOR = "nvim -n -i NONE";
  };

  flake.modules.nixos.neovim = {
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
    };
  };
}
