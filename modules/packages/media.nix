{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        imagemagick
        mupdf
        qpdf
        texlab
        texliveFull
        tinymist
        typst
        yt-dlp
      ];
    };
}
