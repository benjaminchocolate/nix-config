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
      "cmake"
      "llvm"
      "cloudflare-wrangler"
      "container"
      "gh"
      "just"
      "nixfmt"
      "vscode-langservers-extracted"
      "rclone"
      "mupdf"
      "pandoc"
      "qpdf"
      "typst"
      "cheat"
      "navi"
      "tlrc"
      "python"
      "uv"
      "zig@0.17"
      "zls"
      "aria2"
      "ffmpeg"
      "imagemagick"
      "wget"
      "yt-dlp"
      "bash"
      "starship"
      "zsh-autocomplete"
      "zsh-autosuggestions"
      "zsh-completions"
      "zsh-history-substring-search"
      "zsh-syntax-highlighting"
      "age"
      "sops"
      "fastfetch"
      "mole"
      "sequoia-sq"
      "xdg-ninja"
      "mas"
      "zoxide"
      "eza"
      "bat"
      "ripgrep"
      "fd"
      "shellcheck"
      "duti"
      "openai/tools/tart"
      "opencode"
      "pi-coding-agent"
      "mosh"
      "gitleaks"
      "zsh"
    ];

    casks = [
      "mattt/tap/imcp"
      "y3owk1n/tap/neru"
      "nikitabobko/tap/aerospace"
      "motu-m-series"
      "keyboardcleantool"
      "blackhole-2ch"
      "bitwig-studio"
      "surge-xt"
      "ob-xf"
      "valhalla-supermassive"
      "benjaminchocolate/tap/carla-app"
      "tone3000"
      "affinity"
      #"touchdesigner"
      "blender"
      "mixxx"
      "ghostty"
      "wireshark-app"
      #"freecad"
      "kicad"
      "solidcraft"
      "mactex-no-gui"
      "hammerspoon"
      "karabiner-elements"
      "mos"
      "beeper"
      "netnewswire"
      "ungoogled-chromium"
      "moonlight"
      "syntax-highlight"
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
      "font-atkinson-hyperlegible-next"
      "claude"
      "claude-code"
      "anki"
      "antconc"
      "ltspice"
      "benjaminchocolate/tap/mpv-app"
      #"benjaminchocolate/tap/matlab-package-manager"
      #"benjaminchocolate/tap/matlab@2026b"
      "audacity"
      "kdenlive"
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
      # iPad apps not listed?
    };
  };
}
