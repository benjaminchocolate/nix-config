# Emacs (emacs-plus): tap, app, pdf-tools build deps, config link, daemon.
# Everything Emacs lives here. Remove ./emacs.nix from default.nix and all
# of it goes away together (Homebrew cleanup uninstalls the brew side too).
#
# This is a nix-darwin module, but it can still set Home Manager options
# through `home-manager.users.<name>`; they merge with modules/home.
{ config, ... }:
let
  user = config.system.primaryUser;
in
{
  # ── Homebrew side ─────────────────────────────────────────
  # The tap is declared and fully trusted here so that removing this file
  # removes every trace of emacs-plus.
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

  # ── Home Manager side ─────────────────────────────────────
  home-manager.users.${user} = {
    # ~/.config/emacs -> config/emacs in this repo (edit without rebuilding)
    dotfiles.live = [ "emacs" ];

    # Read by emacs-plus at install time only:
    # after changing it, run `brew reinstall --cask emacs-plus-app`
    home.file.".config/emacs-plus/build.yml".text = ''
      icon: liquid-glass
    '';

    # Emacs daemon (emacs-plus cask): starts at login, restarts if it dies
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
