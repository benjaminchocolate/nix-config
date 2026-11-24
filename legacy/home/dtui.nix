{ lib, pkgs, ... }:
let
  emacs = "org.gnu.EmacsClient";
  mail = "com.apple.mail";
  mpv = "io.mpv";
  quicktime = "com.apple.QuickTimePlayerX";

  # UTI = bundle ID. A file's UTI: mdls -name kMDItemContentType <file>
  handlers = {
    # Audio
    "com.apple.m4a-audio" = quicktime;
    "com.microsoft.waveform-audio" = quicktime;
    "org.xiph.flac" = quicktime;
    "org.xiph.ogg-audio" = mpv; # .ogg and .opus; QuickTime can't play them
    "public.aac-audio" = quicktime;
    "public.aiff-audio" = quicktime;
    "public.mp3" = quicktime;

    # Video
    "com.apple.m4v-video" = mpv;
    "com.apple.quicktime-movie" = mpv;
    "org.matroska.mkv" = mpv;
    "org.webmproject.webm" = mpv;
    "public.3gpp" = mpv;
    "public.avi" = mpv;
    "public.mpeg" = mpv;
    "public.mpeg-4" = mpv;

    # Text, code and data
    "com.barebones.bbedit.tex-source" = emacs;
    "dev.nix.source" = emacs;
    "dyn.ah62d4rv4ge81k8pu" = emacs; # .typ
    "dyn.ah62d4rv4ge81y4ph" = emacs; # .zig
    "net.daringfireball.markdown" = emacs;
    "org.lua.lua-source" = emacs;
    "org.n8gray.lisp" = emacs;
    "org.orgmode.org" = emacs;
    "public.c-header" = emacs;
    "public.c-plus-plus-header" = emacs;
    "public.c-plus-plus-source" = emacs;
    "public.c-source" = emacs;
    "public.comma-separated-values-text" = emacs;
    "public.json" = emacs;
    "public.objective-c-source" = emacs;
    "public.plain-text" = emacs;
    "public.python-script" = emacs;
    "public.ruby-script" = emacs;
    "public.shell-script" = emacs;
    "public.swift-source" = emacs;
    "public.toml" = emacs;
    "public.xml" = emacs;
    "public.yaml" = emacs;
  };

  # URL scheme = bundle ID
  schemes = {
    mailto = mail;
  };

  dutiSettings = pkgs.writeText "duti-settings" (
    lib.concatLines (
      lib.mapAttrsToList (uti: app: "${app} ${uti} all") handlers
      ++ lib.mapAttrsToList (scheme: app: "${app} ${scheme}") schemes
    )
  );
in
{
  home.packages = [ pkgs.duti ];

  home.activation.setDefaultApps = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.duti}/bin/duti ${dutiSettings}
  '';
}
