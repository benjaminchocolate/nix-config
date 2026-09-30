{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
    }:
    let
      configuration = { pkgs, ... }: {

        nix.enable = false;

        system.primaryUser = "ben";

        # environment.variables.DOTNET_ROOT = "${pkgs.dotnet-sdk}/share/dotnet";

        # Tools that respect XDG_CACHE_HOME will move their caches from ~/Library/Caches to ~/.cache. Time Machine skips ~/Library/Caches but backs up ~/.cache, so you'd be backing up disposable data. Exclude it once:
        # sudo tmutil addexclusion ~/.cache
        launchd.user.envVariables = {
          XDG_CONFIG_HOME = "/Users/ben/.config";
          XDG_DATA_HOME = "/Users/ben/.local/share";
          XDG_STATE_HOME = "/Users/ben/.local/state";
          XDG_CACHE_HOME = "/Users/ben/.cache";
        };

        # 2. Dock
        system.defaults.dock = {
          autohide = true;
          show-recents = false;
        };

        homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            upgrade = true;
            cleanup = "zap";
          };

          taps = [ "d12frosted/emacs-plus" ];

          brews = [
            "container"
            "cloudflare-wrangler"
            {
              name = "postgresql@18";
              link = true;
            }
            "zsh-autocomplete"
            "zsh-autosuggestions"
            "zsh-completions"
            "zsh-history-substring-search"
            "zsh-syntax-highlighting"
          ];

          casks =
            map
              (name: {
                inherit name;
                greedy = true;
              })
              [
                "affinity"
                "beeper"
                "bitwig-studio"
                "claude"
                "claude-code"
                "coteditor"
                "d12frosted/emacs-plus/emacs-plus-app"
                "ghostty"
                "homebrew-app"
                "karabiner-elements"
                "keyboardcleantool"
                "kindavim"
                "microsoft-teams"
                "mos"
                "motu-m-series"
                "netnewswire"
                "pearcleaner"
                "surge-xt"
                "syntax-highlight"
                "touchdesigner"
                "ungoogled-chromium"
                "zed"
              ];
        };

        security.pam.services.sudo_local.touchIdAuth = true;

        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
          nixfmt
          nixd

          aria2
          bashInteractive
          crystal
          # dotnet-sdk
          fastfetch
          ffmpeg
          ghostscript
          gnupg
          _7zz # official 7-Zip (brew's "sevenzip")
          starship
          tlrc
          uv
          wget
          xdg-ninja
          yt-dlp
        ];

        fonts.packages = [ pkgs.nerd-fonts.fira-code ];

        # Necessary for using flakes on this system.
        #nix.settings.experimental-features = "nix-command flakes";

        # Enable alternative shell support in nix-darwin.
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 6;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Benjamins-MacBook-Pro
      darwinConfigurations."Benjamins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          configuration
          home-manager.darwinModules.home-manager
          {
            # users.users.ben.home = "/Users/ben";

            users.users.ben.home = "/Users/ben";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ben = {
              home.stateVersion = "26.05";

              xdg.enable = true;
              home.preferXdgDirectories = true;

              programs.git = {
                enable = true;
                ignores = [
                  ".DS_Store"
                  "*.swp"
                ];
              };
            };
          }
        ];
      };
    };
}
