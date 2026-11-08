# Shell: aliases and zsh (plugins come from Homebrew, prompt from starship)
{
  home.shellAliases = {
    ls = "ls -la";
    rebuild = "sudo darwin-rebuild switch";
  };

  programs.zsh = {
    enable = true;
    # autosuggestion / syntaxHighlighting / historySubstringSearch lines removed:
    # Brew supplies those plugins now

    profileExtra = ''
      eval "$(/opt/homebrew/bin/brew shellenv)"
    '';

    # The one and only compinit, with zsh-completions added first
    completionInit = ''
      fpath=(/opt/homebrew/share/zsh-completions $fpath)
      autoload -Uz compinit && compinit
    '';

    initContent = ''
      # Completion: case-insensitive matching
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      # Completion: menu you can move through with the arrow keys
      zstyle ':completion:*' menu select

      source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
      source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
      # history-substring-search must load AFTER syntax-highlighting (per its README)
      source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
      bindkey '^[[A' history-substring-search-up    # up arrow
      bindkey '^[[B' history-substring-search-down  # down arrow

      eval "$(/opt/homebrew/bin/starship init zsh)"
    '';
  };
}
