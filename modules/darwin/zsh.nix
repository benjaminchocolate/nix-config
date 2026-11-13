# zsh, system side. The configuration itself is plain files in config/zsh
# (linked to ~/.config/zsh), so this only decides where zsh looks and keeps
# /etc/zshrc from doing work those files already do.
{
  # zsh reads $ZDOTDIR/.zshenv, .zprofile and .zshrc when this is set.
  # It is exported from /etc/zshenv, so no dotfile is needed in ~.
  # "$HOME" is expanded by the shell: root gets /var/root/.config/zsh
  # (which doesn't exist) and never runs my config as root.
  environment.variables.ZDOTDIR = "$HOME/.config/zsh";

  programs.zsh = {
    enableGlobalCompInit = false; # config/zsh/.zshrc runs the one and only compinit
    enableBashCompletion = false; # nothing here uses bash-style completions
    promptInit = ""; # starship draws the prompt
  };
}
