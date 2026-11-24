{
  programs.mpv = {
    enable = true;
    package = null; # mpv itself comes from the mpv-app cask in your tap
    config = {
      hwdec = "auto"; # VideoToolbox on macOS
      profile = "high-quality";
      keep-open = "yes";
      icc-profile-auto = "yes";
    };
  };
}
