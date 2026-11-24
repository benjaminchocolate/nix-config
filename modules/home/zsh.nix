{
  config,
  pkgs,
  ...
}:
let
  cache = "${config.xdg.cacheHome}/zsh";
in
{
  programs.zsh = {
    enable = true;
    package = null; # keep the zsh you log in with for now

    history.path = "${config.xdg.stateHome}/zsh/history";

    completionInit = ''
      mkdir -p "${cache}"
      autoload -Uz compinit
      compinit -d "${cache}/zcompdump-$ZSH_VERSION"
      zstyle ':completion:*' cache-path "${cache}/zcompcache"
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' menu select
    '';

    setOptions = [ "INTERACTIVE_COMMENTS" ];
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    envExtra = "SHELL_SESSIONS_DISABLE=1";
    profileExtra = ''eval "$(/opt/homebrew/bin/brew shellenv)"'';

    shellAliases = {
      ls = "ls -la";
      python = "python3";
      wget = "wget --hsts-file=${config.xdg.stateHome}/wget-hsts";
    };
  };

  programs.starship.enable = true;
  home.packages = [ pkgs.zsh-completions ];
}
