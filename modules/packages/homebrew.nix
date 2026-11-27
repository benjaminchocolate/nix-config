{ inputs, ... }:
{
  flake.modules.darwin.homebrew =
    { config, ... }:
    let
      home = config.users.users.${config.system.primaryUser}.home;
    in
    {
      nix-homebrew.taps = {
        "benjaminchocolate/homebrew-tap" = inputs.homebrew-tap;
        "hammerspoon/homebrew-tap" = inputs.homebrew-hammerspoon;
        "mattt/homebrew-tap" = inputs.homebrew-mattt;
        "nikitabobko/homebrew-tap" = inputs.homebrew-nikitabobko;
        "y3owk1n/homebrew-tap" = inputs.homebrew-y3owk1n;
      };

      homebrew = {
        enable = true;
        greedyCasks = true;
        onActivation = {
          autoUpdate = false; # `just upgrade` updates Homebrew
          upgrade = false;
          cleanup = "uninstall";
          extraEnv.XDG_CONFIG_HOME = "${home}/.config"; # brew reads its trust list from here
        };

        brews = [
          "cloudflare-wrangler"
          "container"
          "mas"
          "mole"
          "opencode"
          "pandoc"
          "pi-coding-agent"
          "python"
          "zls"

          # Disabled
          # "cmake"
          # "llvm"
          # "zig@0.17"
          # "zsh"
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
          "font-ligature-symbols"
          "ghostty"
          "github"
          "hammerspoon"
          "hammerspoon/tap/hammerspoon2"
          "karabiner-elements"
          "kdenlive"
          "keyboardcleantool"
          "kicad"
          "ltspice"
          "mattt/tap/imcp"
          #"mixxx"
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

          # Disabled
          # "benjaminchocolate/tap/matlab-package-manager"
          # "benjaminchocolate/tap/matlab@2026b"
          # "freecad"
          # "touchdesigner"
        ];

        # Not pinned: the App Store always installs the latest version
        masApps = {
          Copilot = 1447330651;
          "Customize Search Engine" = 6445840140;
          "Microsoft Excel" = 462058435;
          "Microsoft Word" = 462054704;
          ScreenZen = 1541027222;
          "SingleFile for Safari" = 6444322545;
          Stremio = 6741710156;
          wBlock = 6746388723;
          Xcode = 497799835;
        };
      };
    };
}
