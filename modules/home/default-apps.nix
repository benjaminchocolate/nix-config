{ pkgs, lib, ... }:
let
  # One handler per UTI. The attrset key is the UTI, the value is the bundle ID.
  handlers = {
    "public.plain-text" = "org.gnu.EmacsClient";
    "public.c-source" = "org.gnu.EmacsClient";
    "public.c-header" = "org.gnu.EmacsClient";
    "public.c-plus-plus-source" = "org.gnu.EmacsClient";
    "public.c-plus-plus-header" = "org.gnu.EmacsClient";
    "com.apple.m4a-audio" = "com.apple.QuickTimePlayerX";
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
