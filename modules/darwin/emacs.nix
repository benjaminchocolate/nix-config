# Emacs (emacs-plus): tap, app, pdf-tools build deps, icon config, daemon.
# Everything Emacs lives here. Remove ./emacs.nix from default.nix and all
# of it goes away together (cleanup = "zap" uninstalls the brew side too).
#
# This is a nix-darwin module, but it can still set Home Manager options
# through `home-manager.users.ben`; they merge with modules/home.
{
  # ── Homebrew side ─────────────────────────────────────────
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
    ];

    casks = [
      {
        name = "d12frosted/emacs-plus/emacs-plus-app";
        greedy = true;
      }
    ];
  };

  # ── Home Manager side ─────────────────────────────────────
  home-manager.users.ben = {
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
        # the cask doesn't inject your PATH, so tools like nixd need this
        EnvironmentVariables.PATH = "/etc/profiles/per-user/ben/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
        ProcessType = "Interactive";
        Nice = -20; # Maybe a bad idea?
      };
    };
  };
}
