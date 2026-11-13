# Session environment: variables that every program should see.
#
# A variable exported in a shell startup file reaches programs started from
# that shell and nothing else. Apps opened from the Dock, Spotlight or at
# login are started by launchd and never read those files. So the same set
# is delivered three ways:
#
#   1. environment.variables       -> /etc/zshenv exports it in every shell
#   2. launchd.user.envVariables   -> `launchctl setenv` when you switch
#   3. the session-env agent below -> `launchctl setenv` again at every login
#
# 3 exists because `launchctl setenv` is forgotten at logout: without it, GUI
# apps lose these variables after every reboot until the next switch.
{ config, lib, ... }:
let
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;

  xdg = {
    config = "${home}/.config";
    data = "${home}/.local/share";
    state = "${home}/.local/state";
    cache = "${home}/.cache";
  };

  sessionEnv = {
    # ── XDG base directories ────────────────────────────────
    # Tools that respect XDG_CACHE_HOME move their caches from ~/Library/Caches
    # to ~/.cache. Time Machine skips the former but backs up the latter;
    # exclude it once with: sudo tmutil addexclusion ~/.cache
    XDG_CONFIG_HOME = xdg.config;
    XDG_DATA_HOME = xdg.data;
    XDG_STATE_HOME = xdg.state;
    XDG_CACHE_HOME = xdg.cache;

    # ── App updaters (Homebrew does the updating) ───────────
    # ELECTRON_NO_UPDATER is read by Bitwarden-style Electron apps only; it
    # is not a general Electron switch.
    ELECTRON_NO_UPDATER = "1";
    DISABLE_UPDATE_CHECK = "1";

    # ── Programs that only use XDG paths when told to ───────
    # From xdg-ninja. Each line keeps one more dotfile out of ~.
    LESSHISTFILE = "${xdg.state}/lesshst";
    SQLITE_HISTORY = "${xdg.state}/sqlite_history";
    NPM_CONFIG_CACHE = "${xdg.cache}/npm";
    DOTNET_CLI_HOME = "${xdg.data}/dotnet";
    BUNDLE_USER_CONFIG = "${xdg.config}/bundle";
    BUNDLE_USER_CACHE = "${xdg.cache}/bundle";
    BUNDLE_USER_PLUGIN = "${xdg.data}/bundle";
    MPLCONFIGDIR = "${xdg.config}/matplotlib";
    TEXMFVAR = "${xdg.cache}/texlive/texmf-var";
    TEXMFCONFIG = "${xdg.config}/texlive/texmf-config";
  };

  # The PATH shells get, with $HOME and $USER filled in, so launchd-started
  # programs (GUI Emacs, the Emacs daemon) find the same tools a shell does.
  guiPath = lib.replaceStrings [ "$HOME" "$USER" ] [ home user ] config.environment.systemPath;

  launchdEnv = sessionEnv // {
    PATH = guiPath;
  };
in
{
  # Shells. PATH is left out here: nix-darwin already builds the shell PATH
  # from environment.systemPath.
  environment.variables = sessionEnv;

  # GUI apps, effective immediately after a switch.
  launchd.user.envVariables = launchdEnv;

  # GUI apps, re-applied at every login. launchd passes its environment to
  # everything it starts afterwards, which includes Dock and Spotlight
  # launches. Apps that macOS reopens at login may start before this runs.
  launchd.user.agents.session-env.serviceConfig = {
    ProgramArguments = [
      "/bin/sh"
      "-c"
      (lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: value: "/bin/launchctl setenv ${name} ${lib.escapeShellArg value}"
        ) launchdEnv
      ))
    ];
    RunAtLoad = true;
  };
}
