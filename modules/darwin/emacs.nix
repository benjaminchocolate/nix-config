{ inputs, ... }:
{
  flake.modules.darwin.emacs =
    { config, pkgs, ... }:
    let
      user = config.system.primaryUser;
    in
    {
      nix-homebrew.taps."d12frosted/homebrew-emacs-plus" = inputs.homebrew-emacs-plus;

      environment.systemPackages = [ pkgs.nixd ]; # eglot's Nix language server

      homebrew = {
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
