{
  flake.modules.darwin.login-items = {
    launchd.user.agents = {
      # -g: don't bring to the front, -j: launch hidden
      background-apps.serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          "/usr/bin/open -gj -a Mail"
        ];
        RunAtLoad = true;
      };

      # Open normally, then hide (for apps that ignore -j).
      hidden-apps.serviceConfig = {
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
