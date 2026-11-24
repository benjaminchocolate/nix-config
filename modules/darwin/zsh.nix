{
  programs.zsh = {
    enableGlobalCompInit = false; # config/zsh/.zshrc runs the one and only compinit
    enableBashCompletion = false; # nothing here uses bash-style completions
    promptInit = ""; # starship draws the prompt
  };
}
