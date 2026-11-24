{ pkgs, ... }:
{
  home.packages = with pkgs; [
    texliveFull
    ffmpeg
    imagemagick
    mupdf
    qpdf
    typst
    yt-dlp
  ];
}
