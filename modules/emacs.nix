{
  flake.modules.darwin.emacs =
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
          "languagetool"

          # pdf-tools needs these to build epdfinfo:
          # "autoconf"
          # "automake"
          # "pkg-config"
          # "poppler"
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

        xdg.configFile."emacs-plus/build.yml".text = ''
          icon: liquid-glass
        '';

        launchd.agents.emacs-daemon = {
          enable = true;
          config = {
            ProgramArguments = [
              "/opt/homebrew/bin/emacs"
              "--fg-daemon"
            ];
            EnvironmentVariables = config.launchd.user.envVariables;
            KeepAlive = true;
            ProcessType = "Interactive";
            RunAtLoad = true;
            StandardErrorPath = "/tmp/emacs-daemon.log";
            StandardOutPath = "/tmp/emacs-daemon.log";
          };
        };
      };
    };
}
