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

    taps = [
      {
        name = "benjaminchocolate/tap";
        trusted = true;
      }
      {
        name = "mattt/tap";
        clone_target = "https://github.com/mattt/homebrew-tap";
        trusted = true;
      }
      {
        name = "y3owk1n/tap";
        clone_target = "https://github.com/y3owk1n/neru";
        trusted = true;
      }
      {
        name = "nikitabobko/tap";
        clone_target = "https://github.com/nikitabobko/homebrew-tap";
        trusted = true;
      }
    ];

    # Groups are alphabetical; so is each group's contents.
    brews = [
      # Build toolchain (C/C++)
      "cmake"
      "gcc"
      "libgccjit"
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

      # GNU Coreutils
      "coreutils"
    ];

    # Groups are alphabetical (Fonts last); so is each group's contents.
    casks =
      map
        (name: {
          inherit name;
          greedy = true;
        })
        [
          # My tap
          "benjaminchocolate/tap/moonlight@nightly"

          # Hardware
          "motu-m-series"
          "keyboardcleantool"

          # Creative: audio
          "blackhole-2ch"
          "bitwig-studio"
          "surge-xt"
          "benjaminchocolate/tap/carla"
          "mixxx"

          # Creative: visual
          "affinity"
          #"touchdesigner"

          # Development
          "claude-code"
          "ghostty"

          # Documents & publishing
          "mactex-no-gui"

          # Input & window management
          "hammerspoon"
          "karabiner-elements"
          "mos"

          # Internet & communication
          "beeper"
          "claude"
          "cloudflare-warp"
          "netnewswire"
          "ungoogled-chromium"

          # Utilities
          "syntax-highlight"

          # Fonts: language coverage (CJK + emoji)
          "font-noto-emoji"
          "font-noto-sans-cjk"
          "font-noto-sans-sc"
          "font-noto-sans-tc"
          "font-noto-sans"
          "font-noto-serif"

          # Fonts: monospace
          "font-0xproto"
          "font-atkinson-hyperlegible-mono"
          "font-fira-code"
          "font-noto-sans-mono"

          # Fonts: symbols, icons & fallback
          "font-gnu-unifont"
          "font-ligature-symbols"
          "font-material-symbols"
          "font-noto-sans-symbols"
          "font-noto-sans-symbols-2"
          "font-powerline-symbols"
          "font-symbols-only-nerd-font"

          # Fonts: text
          "font-atkinson-hyperlegible-next"

          # not sure
          "y3owk1n/tap/neru"
          "anki"
          "iMCP"
          "freecad"
          "kicad"
          "corretto@11" # For Matlab
          "ltspice"
          "aerospace"
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
