{
  flake.modules.homeManager.packages =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        ffmpeg
        imagemagick
        yt-dlp
      ];
    };
}
