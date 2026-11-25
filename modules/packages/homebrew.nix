{
  flake.modules.darwin.packages =
    { config, ... }:
    let
      home = config.users.users.${config.system.primaryUser}.home;
    in
    {
      homebrew = {
        enable = true;
        greedyCasks = true;
        onActivation = {
          autoUpdate = false; # `just upgrade` updates Homebrew
          upgrade = false;
          cleanup = "uninstall";
          extraEnv.XDG_CONFIG_HOME = "${home}/.config"; # trust list in ~/.config/homebrew
        };

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
          "bash"
          "cloudflare-wrangler"
          #"cmake"
          "container"
          #"llvm"
          "mas"
          "mole"
          "openai/tools/tart"
          "opencode"
          "pandoc"
          "pi-coding-agent"
          "python"
          "uv"
          "vscode-langservers-extracted"
          "xdg-ninja"
          #"zig@0.17"
          "zls"
          #"zsh"
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
