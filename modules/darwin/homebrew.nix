{ config, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
      cleanup = "uninstall";

      # Keep brew's trust list in ~/.config/homebrew (not ~/.homebrew)
      extraEnv.XDG_CONFIG_HOME = "${home}/.config";
    };

    greedyCasks = true;

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

    brews = [
      "age"
      "aria2"
      "bash"
      "bat"
      "cheat"
      "cloudflare-wrangler"
      "cmake"
      "container"
      "duti"
      "eza"
      "fastfetch"
      "fd"
      "ffmpeg"
      "gh"
      "gitleaks"
      "imagemagick"
      "just"
      "llvm"
      "mas"
      "mole"
      "mosh"
      "mupdf"
      "navi"
      "nixfmt"
      "openai/tools/tart"
      "opencode"
      "pandoc"
      "pi-coding-agent"
      "python"
      "qpdf"
      "rclone"
      "ripgrep"
      "sequoia-sq"
      "shellcheck"
      "sops"
      "starship"
      "tlrc"
      "typst"
      "uv"
      "vscode-langservers-extracted"
      "wget"
      "xdg-ninja"
      "yt-dlp"
      "zig@0.17"
      "zls"
      "zoxide"
      "zsh"
      "zsh-autocomplete"
      "zsh-autosuggestions"
      "zsh-completions"
      "zsh-history-substring-search"
      "zsh-syntax-highlighting"
    ];

    casks = [
      "affinity"
      "anki"
      "antconc"
      "audacity"
      "beeper"
      "benjaminchocolate/tap/carla-app"
      "benjaminchocolate/tap/mpv-app"
      "bitwig-studio"
      "blackhole-2ch"
      "blender"
      "claude"
      "claude-code"
      "font-0xproto"
      "font-atkinson-hyperlegible-mono"
      "font-atkinson-hyperlegible-next"
      "font-fira-code"
      "font-gnu-unifont"
      "font-ligature-symbols"
      "font-material-symbols"
      "font-noto-emoji"
      "font-noto-sans"
      "font-noto-sans-cjk"
      "font-noto-sans-mono"
      "font-noto-sans-sc"
      "font-noto-sans-symbols"
      "font-noto-sans-symbols-2"
      "font-noto-sans-tc"
      "font-noto-serif"
      "font-powerline-symbols"
      "font-symbols-only-nerd-font"
      "ghostty"
      "github"
      "hammerspoon"
      "karabiner-elements"
      "kdenlive"
      "keyboardcleantool"
      "kicad"
      "ltspice"
      "mactex-no-gui"
      "mixxx"
      "moonlight"
      "mos"
      "motu-m-series"
      "netnewswire"
      "nikitabobko/tap/aerospace"
      "ob-xf"
      "obs"
      "solidcraft"
      "surge-xt"
      "syntax-highlight"
      "tone3000"
      "ungoogled-chromium"
      "valhalla-supermassive"
      "wireshark-app"
      "y3owk1n/tap/neru"
      "mattt/tap/imcp"
      #"benjaminchocolate/tap/matlab-package-manager"
      #"benjaminchocolate/tap/matlab@2026b"
      #"freecad"
      #"touchdesigner"
    ];

    masApps = {
      "Customize Search Engine" = 6445840140;
      "Microsoft Excel" = 462058435;
      "Microsoft Word" = 462054704;
      "SingleFile for Safari" = 6444322545;
      Copilot = 1447330651;
      ScreenZen = 1541027222;
      Stremio = 6741710156;
      wBlock = 6746388723;
      Xcode = 497799835;
      # iPad apps not listed?
    };
  };
}
