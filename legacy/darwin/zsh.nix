# Turns off what /etc/zshrc would duplicate from Home Manager's .zshrc.
{
  programs.zsh = {
    enableBashCompletion = false;
    enableGlobalCompInit = false; # Home Manager runs compinit
    promptInit = ""; # starship draws the prompt
  };
}
