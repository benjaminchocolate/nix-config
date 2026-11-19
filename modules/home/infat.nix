# modules/home/infat.nix
# Default apps for file types and URL schemes, applied on every switch.
{
  programs.infat = {
    enable = true;
    settings = {
      extensions = {
        md = "TextEdit";
        # pdf = "Preview";
        # carxp = "Carla";
        m4a = "QuickTime Player";
        mp3 = "QuickTime Player";
        aac = "QuickTime Player";
        wav = "QuickTime Player";
        aiff = "QuickTime Player";
      };
      schemes = {
        mailto = "Mail";
        #web = "come.apple.Safari";
      };
      types = {
        plain-text = "Emacs Client";
        text = "Emacs Client";
        # csv
        image = "";
        # raw-image
        audio = "QuickTime Player";
        video = "QuickTime Player";
        # movie
        mp4-audio = "QuickTime Player";
        # quicktime
        # mp4-movie
        # archive
        # sourcecode
        c-source = "Emacs Client";
        cpp-source = "Emacs Client";
        objc-source = "Emacs Client";
        # shell
        # makefile
        # data
        # directory
        # folder
        # symlink
        # executable
        # unix-executable
        # app-bundle
      };
    };
  };
}
