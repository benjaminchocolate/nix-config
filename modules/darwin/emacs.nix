{
  config,
  ...
}:
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
      # "pkg-config"
      # "poppler"
      # "autoconf"
      # "automake"
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
        RunAtLoad = true;
        KeepAlive = true;
        StandardOutPath = "/tmp/emacs-daemon.log";
        StandardErrorPath = "/tmp/emacs-daemon.log";
        EnvironmentVariables = config.launchd.user.envVariables;
        ProcessType = "Interactive";
      };
    };
  };
}
