{
  programs.ghostty = {
    enable = true;
    package = null; # Homebrew cask
    enableZshIntegration = false; # Ghostty injects its own
    settings.keybind = [
      "ctrl+h=goto_split:left"
      "ctrl+l=goto_split:right"
    ];
  };
}
