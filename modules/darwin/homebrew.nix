# Homebrew: the installation itself (nix-homebrew), activation behaviour, and
# the general package lists. Feature modules (like emacs.nix) add their own
# taps/brews/casks; Nix merges every module's lists into one Brewfile.
#
# Two modules cooperate here:
#   nix-homebrew  installs Homebrew and its taps from pinned flake inputs
#   homebrew      (nix-darwin) runs `brew bundle` with a generated Brewfile
{
  config,
  inputs,
  lib,
  ...
}:
let
  home = config.users.users.${config.system.primaryUser}.home;

  # "owner/homebrew-name" (the repository) -> "owner/name" (what brew calls it)
  tapName = lib.replaceStrings [ "/homebrew-" ] [ "/" ];
in
{
  imports = [ inputs.nix-homebrew.darwinModules.nix-homebrew ];

  # ── Homebrew itself ───────────────────────────────────────
  nix-homebrew = {
    enable = true;
    user = config.system.primaryUser;

    # Take over the Homebrew that the official installer put in /opt/homebrew:
    # its own code is removed, installed packages are kept. Only does anything
    # on the first switch; harmless afterwards.
    autoMigrate = true;

    # Strict mode: /opt/homebrew/Library/Taps becomes a read-only link into
    # the Nix store. `brew tap` and `brew update` stop working on purpose.
    mutableTaps = false;

    # Keys are "<owner>/homebrew-<name>" (the repository name), values are
    # flake inputs. Feature modules add their own (see emacs.nix).
    taps = {
      "homebrew/homebrew-core" = inputs.homebrew-core;
      "homebrew/homebrew-cask" = inputs.homebrew-cask;
      "benjaminchocolate/homebrew-tap" = inputs.homebrew-tap;
      "mattt/homebrew-tap" = inputs.homebrew-mattt;
      "nikitabobko/homebrew-tap" = inputs.homebrew-nikitabobko;
      "y3owk1n/homebrew-tap" = inputs.homebrew-y3owk1n;
    };

    # Trust policy. Homebrew refuses to load anything from a non-official tap
    # unless it is trusted (https://docs.brew.sh/Tap-Trust).
    #
    #   Whole tap:   listed here. Only taps I would run any future code from.
    #                (emacs.nix adds d12frosted/emacs-plus.)
    #   Single cask: no list. Writing a cask as "owner/tap/name" in `casks`
    #                below trusts exactly that cask (nix-darwin adds
    #                `trusted: true` to its Brewfile line).
    #
    # The Brewfile is the authority: on every switch `brew bundle cleanup`
    # resets brew's trust file to what the Brewfile declares. That is why
    # `homebrew.taps` below copies this list into the Brewfile; trust set only
    # here would be wiped again minutes later.
    trust.taps = [ "benjaminchocolate/tap" ];

    # Exported inside bin/brew, so every brew run (terminal, activation, GUI)
    # keeps its trust list in ~/.config/homebrew instead of ~/.homebrew.
    extraEnv.XDG_CONFIG_HOME = "${home}/.config";
    extraEnv.HOMEBREW_DEVELOPER = "1";

    # My zsh config runs `brew shellenv` once in .zprofile; without this
    # nix-homebrew would run it again in /etc/zshrc for every shell.
    enableZshIntegration = false;
  };

  # ── What brew bundle does on every switch ─────────────────
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false; # nothing to fetch: taps are pinned flake inputs
      upgrade = true; # move installed packages to the pinned taps' versions
      # Uninstall anything brew has that no module lists. "zap" would also
      # delete the app's preferences and data; "check" would only refuse to
      # switch and print the list.
      cleanup = "uninstall";
    };

    greedyCasks = true;

    # The Brewfile's tap lines are generated from the pinned taps above, so
    # the two lists cannot drift. (Cleanup untaps anything missing from the
    # Brewfile, which would fail on the read-only tap directory.) A tap in
    # the trust list gets `trusted: true`.
    taps = map (name: {
      inherit name;
      trusted = builtins.elem (tapName name) config.nix-homebrew.trust.taps;
    }) (builtins.attrNames config.nix-homebrew.taps);

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
