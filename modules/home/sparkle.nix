{
  flake.modules.homeManager.sparkle =
    { lib, ... }:
    {
      home.activation.disableSparkleUpdates = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        for app in /Applications/*.app; do
          [ -d "$app/Contents/Frameworks/Sparkle.framework" ] || continue
          id=$(/usr/bin/defaults read "$app/Contents/Info" CFBundleIdentifier 2>/dev/null) || continue
          run /usr/bin/defaults write "$id" SUEnableAutomaticChecks -bool false
          run /usr/bin/defaults write "$id" SUAutomaticallyUpdate -bool false
        done
      '';
    };
}
