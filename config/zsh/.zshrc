# .zshrc: interactive shells. Plugins come from Homebrew, the prompt from starship.

# ── Where zsh keeps its own files ─────────────────────────
# History is state, completion dumps are cache. Neither belongs in this
# directory, which is a git checkout.
: ${XDG_STATE_HOME:=$HOME/.local/state} ${XDG_CACHE_HOME:=$HOME/.cache}
[[ -d $XDG_STATE_HOME/zsh ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d $XDG_CACHE_HOME/zsh ]] || mkdir -p "$XDG_CACHE_HOME/zsh"

# ── History ───────────────────────────────────────────────
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_FCNTL_LOCK    # lock the file properly when several shells write
setopt HIST_IGNORE_DUPS   # skip a command identical to the previous one
setopt HIST_IGNORE_SPACE  # a leading space keeps a command out of history
setopt SHARE_HISTORY      # all open shells read and write one history

# ── Completion ────────────────────────────────────────────
typeset -U path fpath  # no duplicate entries
fpath=(/opt/homebrew/share/zsh-completions $fpath)

# The one and only compinit (/etc/zshrc's is turned off in zsh.nix).
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/zcompdump-$ZSH_VERSION"

zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'  # case-insensitive
zstyle ':completion:*' menu select                         # arrow-key menu

# ── Plugins (Homebrew) ────────────────────────────────────
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# history-substring-search must load AFTER syntax-highlighting (per its README)
source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey '^[[A' history-substring-search-up    # up arrow
bindkey '^[[B' history-substring-search-down  # down arrow

# ── Prompt ────────────────────────────────────────────────
eval "$(/opt/homebrew/bin/starship init zsh)"

# ── direnv ────────────────────────────────────────────────
# Loads a directory's .envrc on cd. Installed by Nix (modules/home/default.nix).
(( $+commands[direnv] )) && eval "$(direnv hook zsh)"

# ── Aliases ───────────────────────────────────────────────
alias ls='ls -la'
# wget has no setting for this file's location, only a flag.
alias wget='wget --hsts-file="$XDG_STATE_HOME/wget-hsts"'
# Run this repo's justfile from any directory: `dots switch`, `dots update`.
# Plain `dots` lists the recipes.
alias dots='just --justfile ~/Developer/dotfiles/justfile'

alias python='python3'

if [[ -n $GHOSTTY_RESOURCES_DIR ]]; then
  source "$GHOSTTY_RESOURCES_DIR"/shell-integration/zsh/ghostty-integration
fi
