{
  description = "My first nix-darwin flake";

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

        system.defaults.screencapture = {
          disable-shadow = true;
          include-date = true;
          location = "/Users/ben/Pictures/Screenshots";
          show-thumbnail = true;
          type = "png";
        };

        system.defaults.CustomUserPreferences = {
          "com.apple.finder" = {
            # NSUserKeyEquivalents = { "Close Window" = "@q"; };  # already have this
            _FXEnableColumnAutoSizing = true; # new
          };
          "com.apple.TextEdit".RichText = false;
        };

        networking.applicationFirewall = {
          enable = true;
          enableStealthMode = true;
          allowSigned = false;
          allowSignedApp = false;
          blockAllIncoming = false; # must stay off, or the allowlist is ignored
        };

        # 2. Dock
        system.defaults.dock = {
          orientation = "bottom";
          mineffect = "genie";
          tilesize = 64; # normal icon size in pixels (16–128)
          magnification = true; # enlarge icons on hover
          largesize = 72; # magnified size in pixels (16–128)
          autohide = true;
          show-recents = false;
        };

        system.defaults.WindowManager = {
          GloballyEnabled = false; # Stage Manager off
          StandardHideDesktopIcons = true; # hide desktop files
          StandardHideWidgets = true; # hide desktop widgets
          StageManagerHideWidgets = true; # hide them if Stage Manager ever gets turned on
          EnableStandardClickToShowDesktop = false;
        };

        system.defaults.finder = {
          FXPreferredViewStyle = "clmv"; # column view (your pick)
          AppleShowAllExtensions = true; # always show .pdf, .zip, etc.
          FXEnableExtensionChangeWarning = false; # no prompt when renaming an extension
          ShowPathbar = true; # breadcrumb path at the bottom
          ShowStatusBar = true; # item count and free space
          _FXShowPosixPathInTitle = true; # full path in the window title
          _FXSortFoldersFirst = true; # folders above files, like ls
          FXDefaultSearchScope = "SCcf"; # search the current folder, not the whole Mac
          NewWindowTarget = "Home"; # new windows open in ~
          #FXRemoveOldTrashItems = true; # empty Trash items after 30 days
          AppleShowAllFiles = true;
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
            users.users.ben.home = "/Users/ben";
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ben = { pkgs, ... }: {
              home.stateVersion = "26.05";
              manual.manpages.enable = false;

              xdg.enable = true;
              home.preferXdgDirectories = true;

              home.packages = with pkgs; [
                bun
                zsh-completions
              ];

              home.shellAliases.rebuild = "sudo darwin-rebuild switch";

              programs.git = {
                enable = true;
                ignores = [
                  ".DS_Store"
                  "*.swp"
                  ".direnv/"
                  "result"
                ];
                settings = {
                  user = {
                    name = "Benjamin Carpenter";
                    email = "benjamin.carpenter@mailbox.org";
                    signingkey = "/Users/ben/.ssh/id_ed25519.pub";
                  };
                  gpg.format = "ssh";
                  commit.gpgsign = true;
                  tag.gpgsign = true;
                };
              };

              programs.starship.enable = true;

              programs.zsh = {
                enable = true;
                autosuggestion.enable = true;
                syntaxHighlighting.enable = true;
                historySubstringSearch.enable = true;

                profileExtra = ''
                  eval "$(/opt/homebrew/bin/brew shellenv)"
                '';

                initContent = ''
                  zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
                  zstyle ':completion:*' menu select

                  fastfetch
                '';
              };
            };
          }
        ];
      };
    };
}
