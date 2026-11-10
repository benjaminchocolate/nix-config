# Login items, session environment, and system services (root daemons)
{
  # ── Login items & session environment ─────────────────────
  launchd.user = {
    # $XDG_RUNTIME_DIR
    # Tools that respect XDG_CACHE_HOME will move their caches from ~/Library/Caches to ~/.cache.
    # Time Machine skips ~/Library/Caches but backs up ~/.cache, so you'd be backing up
    # disposable data. Exclude it once:
    # sudo tmutil addexclusion ~/.cache
    envVariables = {
      XDG_CONFIG_HOME = "/Users/ben/.config";
      XDG_DATA_HOME = "/Users/ben/.local/share";
      XDG_STATE_HOME = "/Users/ben/.local/state";
      XDG_CACHE_HOME = "/Users/ben/.cache";
      ELECTRON_NO_UPDATER = "1";
    };

    # Open these apps in the background at login
    agents.background-apps = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          #"/usr/bin/open -gj -a Calendar; /usr/bin/open -gj -a Mail; /usr/bin/open -gj -a Messages; /usr/bin/open -gj -a Music; /usr/bin/open -gj -a Reminders"
          "/usr/bin/open -gj -a Mail"
        ];
        RunAtLoad = true;
      };
    };

    # Open these apps at login, then hide them
    agents.hidden-apps = {
      serviceConfig = {
        # ScreenZen
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            apps="Claude"
            for app in $apps; do /usr/bin/open -a "$app"; done
            sleep 1
            for app in $apps; do
              /usr/bin/osascript -e "tell application \"System Events\" to set visible of process \"$app\" to false"
            done
          ''
        ];
        RunAtLoad = true;
      };
    };

    agents.reset-finder-views = {
      script = ''
        /usr/bin/find /Users/ben -path /Users/ben/Library -prune -o -name .DS_Store -type f -delete
        /usr/bin/killall Finder
      '';
      serviceConfig = {
        RunAtLoad = true; # run once at login
        StandardErrorPath = "/tmp/reset-finder-views.err";
      };
    };
  };

  # ── System services (run as root) ─────────────────────────
  # Sweep .DS_Store across the disk at boot and daily at 4am
  launchd.daemons.clean-ds-store = {
    script = ''
      /usr/bin/find /Users /Applications /Library -name .DS_Store -type f -delete
    '';
    serviceConfig = {
      RunAtLoad = true;
      StartCalendarInterval = [
        {
          Hour = 4;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/var/log/clean-ds-store.err";
    };
  };
}
