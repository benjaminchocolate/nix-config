{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ffmpeg
    imagemagick
    mupdf
    qpdf
    typst
    yt-dlp
  ];
}
