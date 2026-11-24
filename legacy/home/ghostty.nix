{
  programs.ghostty = {
    enable = true;
    package = null; # Homebrew cask
    enableZshIntegration = false; # Ghostty injects its own
    settings = {
      theme = "Clear Dark";
      #background-opacity = 0.85;
      #background-blur = "macos-glass-regular";
      font-family = "Atkinson Hyperlegible Mono";
      font-size = 15;
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];
    };
  };
}
