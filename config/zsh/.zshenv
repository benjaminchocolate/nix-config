# .zshenv: read by every zsh, including scripts. Environment only, keep it fast.
#
# zsh finds this directory through $ZDOTDIR, which Nix exports in /etc/zshenv
# (modules/darwin/zsh.nix). ~/.config/zsh is a link to config/zsh in the
# dotfiles repo, so edits here apply to the next shell without a rebuild.

# Variables that Home Manager modules define (home.sessionVariables).
# Home Manager doesn't manage zsh in this setup, so this is the one hook.
hm_session_vars="/etc/profiles/per-user/$USER/etc/profile.d/hm-session-vars.sh"
[[ -r $hm_session_vars ]] && source "$hm_session_vars"
unset hm_session_vars

# Apple's Terminal.app saves per-window history in ~/.zsh_sessions. Opt out.
SHELL_SESSIONS_DISABLE=1
