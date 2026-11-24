{
  programs.ghostty = {
    enable = true;
    package = null;
    enableZshIntegration = false; # Ghostty injects this itself
    settings = {
      keybind = [
        "ctrl+h=goto_split:left"
        "ctrl+l=goto_split:right"
      ];
    };
  };
}
