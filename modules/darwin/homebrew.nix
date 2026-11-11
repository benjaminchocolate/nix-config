# Homebrew: activation behaviour and the general package lists.
# Feature modules (like emacs.nix) add their own taps/brews/casks;
# Nix merges every module's lists into one Brewfile.
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "zap"; # WARNING: uninstalls AND zaps anything not listed in ANY module
    };

    greedyCasks = true;

    taps = [
      {
        name = "benjaminchocolate/tap";
        trusted = true;
      }
    ];

    # Groups are alphabetical; so is each group's contents.
    brews = [
      # Build toolchain (C/C++)
      "cmake"
      "llvm"

      # Dev tools & cloud
      "cloudflare-wrangler"
      "container"
      "gh"
      "nixfmt"
      "vscode-langservers-extracted"

      # Documents & publishing
      "mupdf"
      "pandoc"
      "typst"

      # Help & cheatsheets
      "cheat"
      "navi"
      "tlrc"

      # Languages & runtimes
      "python"
      "uv"
      "zig@0.17"
      "zls"

      # Media & downloads
      "aria2"
      "ffmpeg"
      "imagemagick"
      "wget"
      "yt-dlp"

      # Shell
      "bash"
      "starship"
      "zsh-autocomplete"
      "zsh-autosuggestions"
      "zsh-completions"
      "zsh-history-substring-search"
      "zsh-syntax-highlighting"

      # System utilities
      #"cf" # NOTE: timestamp formatter, not a Cloudflare CLI (check with `brew info cf`)
      "fastfetch"
      "mole"
      "sequoia-sq"
      "xdg-ninja"
      "mas"

      # testing out
      "zoxide"
      "eza"
      "bat"
      "ripgrep"
      "fd"
      "shellcheck"

    ];

    # Groups are alphabetical (Fonts last); so is each group's contents.
    casks = [
      "mattt/tap/imcp"
      "y3owk1n/tap/neru"
      "nikitabobko/tap/aerospace"

      # Hardware
      "motu-m-series"
      "keyboardcleantool"

      # Creative: audio
      "blackhole-2ch"

      # Creative
      "affinity"
      #"touchdesigner"
      "blender"
      "bitwig-studio"
      "surge-xt"
      "benjaminchocolate/tap/carla-app"
      "mixxx"

      # Engineering & development
      "ghostty"
      "wireshark-app"
      "freecad"
      "kicad"

      # Documents & publishing
      "mactex-no-gui"

      # Input & window management
      "hammerspoon"
      "karabiner-elements"
      "mos"
      #"y3owk1n/tap/neru"
      #"aerospace"

      # Internet & communication
      "beeper"
      # "cloudflare-warp"
      "netnewswire"
      "ungoogled-chromium"
      "benjaminchocolate/tap/moonlight@nightly"

      # Utilities
      "syntax-highlight"

      # Fonts
      "font-noto-emoji"
      "font-noto-sans-cjk"
      "font-noto-sans-sc"
      "font-noto-sans-tc"
      "font-noto-sans"
      "font-noto-serif"
      "font-0xproto"
      "font-atkinson-hyperlegible-mono"
      "font-fira-code"
      "font-noto-sans-mono"
      "font-gnu-unifont"
      "font-ligature-symbols"
      "font-material-symbols"
      "font-noto-sans-symbols"
      "font-noto-sans-symbols-2"
      "font-powerline-symbols"
      "font-symbols-only-nerd-font"

      # Fonts: text
      "font-atkinson-hyperlegible-next"

      # AI
      "claude"
      "claude-code"
      #"iMCP"

      "anki"

      # For school
      "corretto@11" # For Matlab
      "antconc" # For DTC 375
      "ltspice"
    ];

    masApps = {
      Xcode = 497799835;
      Copilot = 1447330651;
      Stremio = 6741710156;
      wBlock = 6746388723;
      "Customize Search Engine" = 6445840140;
      "SingleFile for Safari" = 6444322545;
      "Microsoft Excel" = 462058435;
      "Microsoft Word" = 462054704;
      ScreenZen = 1541027222;
    };
  };
}
