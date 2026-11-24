# Default apps, reapplied on every switch (overrides changes made in Finder).
{
  programs.infat = {
    enable = true;
    settings = {
      extensions = {
        aac = "QuickTime Player";
        aiff = "QuickTime Player";
        m4a = "QuickTime Player";
        md = "TextEdit";
        mp3 = "QuickTime Player";
        wav = "QuickTime Player";
      };
      schemes.mailto = "Mail";
      types = {
        audio = "QuickTime Player";
        c-source = "Emacs Client";
        cpp-source = "Emacs Client";
        image = "";
        mp4-audio = "QuickTime Player";
        objc-source = "Emacs Client";
        plain-text = "Emacs Client";
        text = "Emacs Client";
        video = "QuickTime Player";
      };
    };
  };
}
