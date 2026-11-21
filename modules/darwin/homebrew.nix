# Homebrew: activation behaviour and the general package lists. Homebrew
# itself is a normal install from the official installer in /opt/homebrew;
# nix-darwin only runs `brew bundle` with a generated Brewfile. Feature
# modules (like emacs.nix) add their own taps/brews/casks; Nix merges every
# module's lists into one Brewfile.
{ config, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  # ── What brew bundle does on every switch ─────────────────
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true; # `brew update` (taps and Homebrew itself) on every switch
      upgrade = true; # upgrade outdated packages on every switch
      # Uninstall anything brew has that no module lists. "zap" would also
      # delete the app's preferences and data; "check" would only refuse to
      # switch and print the list.
      cleanup = "uninstall";

      # Keep brew's trust list in ~/.config/homebrew (not ~/.homebrew), the
      # same place my shells use (XDG_CONFIG_HOME in environment.nix).
      extraEnv.XDG_CONFIG_HOME = "${home}/.config";
    };

    greedyCasks = true;

    # Trust policy. Homebrew refuses to load anything from a non-official tap
    # unless it is trusted (https://docs.brew.sh/Tap-Trust).
    #
    #   Whole tap:   `trusted = true` below. Only taps I would run any future
    #                code from. (emacs.nix adds d12frosted/emacs-plus.)
    #   Single cask: writing a cask as "owner/tap/name" in `casks` trusts
    #                exactly that cask (nix-darwin adds `trusted: true` to its
    #                Brewfile line).
    #
    # The Brewfile is the authority: on every switch `brew bundle cleanup`
    # resets brew's trust file to what the Brewfile declares, and untaps any
    # tap that no module lists.
    taps = [
      {
        name = "benjaminchocolate/tap";
        trusted = true;
      }
      {
        name = "openai/tools";
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
      "just" # runs this repo's justfile
      "nixfmt"
      "vscode-langservers-extracted"

      # Documents & publishing
      "mupdf"
      "pandoc"
      "qpdf" # was installed by hand on 2026-11-10; delete this line if it was a one-off
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

      # Secrets (used by `just secrets-*`; see modules/home/secrets.nix)
      "age"
      "sops"

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

      "duti"

      # "infat"

      "openai/tools/tart"

      "opencode"

      "pi-coding-agent"
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
      "bitwig-studio"
      "surge-xt"
      "ob-xf"
      "valhalla-supermassive"
      "benjaminchocolate/tap/carla-app"
      "tone3000"
      # "cardinal"
      # "dexed"

      # Creative
      "affinity"
      #"touchdesigner"
      "blender"
      "mixxx"

      # Engineering & development
      "ghostty"
      "wireshark-app"
      # "freecad"
      "kicad"
      "solidcraft"

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
      # "benjaminchocolate/tap/moonlight@nightly"
      "moonlight"

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

      "benjaminchocolate/tap/mpv-app"

      "audacity"
      #"filmcraft"
      #"kdenlive"
      "obs"

      "github"

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
      # medito?
    };
  };
}
