# Apps started by launchd (Dock, Spotlight, login) never read shell startup
# files, so these variables are set three ways: environment.variables for
# shells, launchd.user.envVariables at every switch, and the session-env
# agent at every login (`launchctl setenv` is forgotten at logout).
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
    # Time Machine backs up ~/.cache but not ~/Library/Caches; exclude it
    # once with: sudo tmutil addexclusion ~/.cache
    XDG_CONFIG_HOME = xdg.config;
    XDG_DATA_HOME = xdg.data;
    XDG_STATE_HOME = xdg.state;
    XDG_CACHE_HOME = xdg.cache;

    # Homebrew does the updating. ELECTRON_NO_UPDATER only affects some
    # Electron apps (Bitwarden-style); it is not a general Electron switch.
    ELECTRON_NO_UPDATER = "1";
    DISABLE_UPDATE_CHECK = "1";

    # From xdg-ninja: programs that use XDG paths only when told to.
    BUNDLE_USER_CACHE = "${xdg.cache}/bundle";
    BUNDLE_USER_CONFIG = "${xdg.config}/bundle";
    BUNDLE_USER_PLUGIN = "${xdg.data}/bundle";
    DOTNET_CLI_HOME = "${xdg.data}/dotnet";
    LESSHISTFILE = "${xdg.state}/lesshst";
    MPLCONFIGDIR = "${xdg.config}/matplotlib";
    NPM_CONFIG_CACHE = "${xdg.cache}/npm";
    SQLITE_HISTORY = "${xdg.state}/sqlite_history";
    TEXMFCONFIG = "${xdg.config}/texlive/texmf-config";
    TEXMFVAR = "${xdg.cache}/texlive/texmf-var";
  };

  # The shell PATH with $HOME and $USER filled in, so GUI apps and the
  # Emacs daemon find the same tools a shell does.
  launchdEnv = sessionEnv // {
    PATH = lib.replaceStrings [ "$HOME" "$USER" ] [ home user ] config.environment.systemPath;
  };
in
{
  # nix-darwin already builds the shell PATH from environment.systemPath.
  environment.variables = sessionEnv;

  launchd.user.envVariables = launchdEnv;

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
