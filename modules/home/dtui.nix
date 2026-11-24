{ pkgs, lib, ... }:
let
  # One handler per UTI. The attrset key is the UTI, the value is the bundle ID.
  handlers = {
    "com.apple.m4a-audio" = "com.apple.QuickTimePlayerX";
    "public.mp3" = "com.apple.QuickTimePlayerX";
    "public.aac-audio" = "com.apple.QuickTimePlayerX";
    "public.aiff-audio" = "com.apple.QuickTimePlayerX";
    "com.microsoft.waveform-audio" = "com.apple.QuickTimePlayerX";
    "net.daringfireball.markdown" = "com.apple.TextEdit";
    "public.plain-text" = "org.gnu.EmacsClient";
    "public.c-source" = "org.gnu.EmacsClient";
    # ...
  };

  # Turn the attrset into duti's "bundle-id  UTI  role" lines.
  dutiSettings = pkgs.writeText "duti-settings" (
    lib.concatStringsSep "\n" (lib.mapAttrsToList (uti: app: "${app} ${uti} all") handlers) + "\n"
  );
in
{
  home.packages = [ pkgs.duti ];

  home.activation.setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.duti}/bin/duti ${dutiSettings}
  '';
}
