{
  flake.modules.homeManager.mpv = {
    programs.mpv = {
      enable = true;
      package = null; # mpv-app cask from my tap
      config = {
        hwdec = "auto";
        icc-profile-auto = "yes";
        keep-open = "yes";
        profile = "high-quality";
      };
    };
  };
}
