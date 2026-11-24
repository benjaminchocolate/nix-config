{ config, ... }:
let
  user = config.system.primaryUser;
in
{
  homebrew = {
    taps = [
      {
        name = "d12frosted/emacs-plus";
        trusted = true;
      }
    ];

    brews = [
      # pdf-tools build deps
      "pkg-config"
      "poppler"
      "autoconf"
      "automake"
      "languagetool"
    ];

    casks = [
      {
        name = "d12frosted/emacs-plus/emacs-plus-app";
        greedy = true;
      }
    ];
  };

  home-manager.users.${user} = {
    # ~/.config/emacs -> config/emacs in this repo (edit without rebuilding)
    dotfiles.live = [ "emacs" ];

    home.file.".config/emacs-plus/build.yml".text = ''
      icon: liquid-glass
    '';

    launchd.agents.emacs-daemon = {
      enable = true;
      config = {
        ProgramArguments = [
          "/opt/homebrew/bin/emacs"
          "--fg-daemon"
        ];
        RunAtLoad = true; # start at login
        KeepAlive = true; # restart if it dies
        StandardOutPath = "/tmp/emacs-daemon.log";
        StandardErrorPath = "/tmp/emacs-daemon.log";
        # launchd starts this with an almost empty environment. Give it the
        # session environment (environment.nix) directly: PATH so it finds
        # nixd, TeX and Homebrew tools, plus the XDG variables. The login
        # agent sets the same values, but may run after this daemon starts.
        EnvironmentVariables = config.launchd.user.envVariables;
        ProcessType = "Interactive";
        Nice = -20; # Maybe a bad idea?
      };
    };
  };
}
