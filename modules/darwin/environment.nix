# GUI apps never read shell startup files, so these are set three ways:
# shells (environment.variables), every switch (launchd.user.envVariables),
# and every login (session-env agent; `launchctl setenv` is lost at logout).
{
  flake.modules.darwin.environment =
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
        XDG_CONFIG_HOME = xdg.config;
        XDG_DATA_HOME = xdg.data;
        XDG_STATE_HOME = xdg.state;
        XDG_CACHE_HOME = xdg.cache;

        # Homebrew does the updating
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

      # Same PATH as a shell, so GUI apps and the Emacs daemon find the same tools
      launchdEnv = sessionEnv // {
        PATH = lib.replaceStrings [ "$HOME" "$USER" ] [ home user ] config.environment.systemPath;
      };
    in
    {
      # No PATH here: nix-darwin builds the shell PATH from systemPath
      environment.variables = sessionEnv;
      environment.systemPath = [
        "/opt/homebrew/bin"
        "${home}/.local/bin"
      ];

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
    };
}
