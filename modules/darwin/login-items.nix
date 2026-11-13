# Login items: apps to open when I log in.
# (Session environment variables moved to environment.nix.)
{
  launchd.user = {
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
  };
}
