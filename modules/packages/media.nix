{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        imagemagick
        mupdf
        qpdf
        texliveFull
        typst
        yt-dlp
      ];
    };
}
