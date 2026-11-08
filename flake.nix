{
  description = "My Determinate Nix-nix-darwin flake";

  inputs = {
    # Unstable Nixpkgs repository
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    # System configuration management
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # User configuration management
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Homebrew management
    # NOTE: nix-homebrew and the two tap inputs below are fetched but never
    # added to `modules`, so right now they do nothing.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Optional: Declarative tap management
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;

    };

    # secrets
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
      home-manager,
      nix-homebrew,
      homebrew-core,
      homebrew-cask,
      sops-nix,
    }:
    let
      # ==============================================================
      # SYSTEM (nix-darwin): machine-wide settings, macOS, Homebrew
      # ==============================================================
      systemConfig =
        { pkgs, ... }:
        {
          # ── Nix & platform ────────────────────────────────────────
          nix.enable = false; # Determinate Nix manages the Nix daemon

          # Necessary for using flakes on this system.
          #nix.settings.experimental-features = "nix-command flakes";

          # The platform the configuration will be used on.
          nixpkgs.hostPlatform = "aarch64-darwin";

          # Set Git commit hash for darwin-version.
          system.configurationRevision = self.rev or self.dirtyRev or null;

          # Used for backwards compatibility, please read the changelog before changing.
          # $ darwin-rebuild changelog
          system.stateVersion = 6;

          # ── User & shells ─────────────────────────────────────────
          system.primaryUser = "ben";
          users.users.ben.home = "/Users/ben";

          # Enable alternative shell support in nix-darwin.
          # programs.fish.enable = true;

          # ── Security ──────────────────────────────────────────────
          security.pam.services.sudo_local.touchIdAuth = true;

          networking.applicationFirewall = {
            enable = true;
            enableStealthMode = true;
            allowSigned = false;
            allowSignedApp = false;
            blockAllIncoming = false; # must stay off, or the allowlist is ignored
          };

          # ── Nix packages & fonts ──────────────────────────────────
          # List packages installed in system profile. To search by name, run:
          # $ nix-env -qaP | grep wget
          environment.systemPackages = with pkgs; [
            #dvipng
            nixd
            #(texliveFull.withPackages (
            #  ps: with ps; [
            #    dvipng
            #  ]
            #))
          ];

          # Fonts are installed as Homebrew casks (see "Fonts" in homebrew.casks).
          # Nixpkgs equivalents, kept for reference:
          fonts.packages = [
          ];

          # ── macOS defaults ────────────────────────────────────────
          system.defaults = {
            dock = {
              orientation = "bottom";
              mineffect = "genie";
              tilesize = 64; # normal icon size in pixels (16–128)
              magnification = true; # enlarge icons on hover
              largesize = 72; # magnified size in pixels (16–128)
              autohide = true;
              show-recents = false;
            };

            finder = {
              CreateDesktop = false; # don't draw the desktop at all
              FXPreferredViewStyle = "Nlsv"; # list view
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

            screencapture = {
              disable-shadow = true;
              include-date = true;
              location = "/Users/ben/Pictures/Screenshots";
              show-thumbnail = true;
              type = "png";
            };

            WindowManager = {
              GloballyEnabled = false; # Stage Manager off
              StandardHideDesktopIcons = true; # hide desktop files
              StandardHideWidgets = true; # hide desktop widgets
              StageManagerHideWidgets = true; # hide them if Stage Manager ever gets turned on
              EnableStandardClickToShowDesktop = false;
            };

            # Per-app preferences: same as `defaults write <domain> <key> <value>`
            CustomUserPreferences = {
              "com.apple.finder" = {
                # NSUserKeyEquivalents = { "Close Window" = "@q"; };  # already have this
                _FXEnableColumnAutoSizing = true;
              };

              "com.apple.desktopservices" = {
                DSDontWriteNetworkStores = true; # SMB/NFS shares
                DSDontWriteUSBStores = true; # external drives
              };

              "com.apple.Safari" = {
                IncludeDevelopMenu = true;
                WebKitDeveloperExtrasEnabledPreferenceKey = true;
                "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;

                WebKitExperimentalPreferPageRenderingUpdatesNear60FPSEnabled = false;
              };

              "com.apple.TextEdit" = {
                RichText = false;
                NSFont = "Atkinson Hyperlegible Next Regular";
                NSFontSize = 15;
                NSFixedPitchFont = "Atkinson Hyperlegible Next Mono";
                NSFixedPitchFontSize = 15;
              };

              "org.hammerspoon.Hammerspoon".MJConfigFile = "~/.config/hammerspoon/init.lua";

              # System-wide UI font (disabled)
              #NSGlobalDomain = {
              #  NSFont = "Atkinson Hyperlegible Next";
              #  NSFontSize = 15;
              #  NSFixedPitchFont = "Atkinson Hyperlegible Mono";
              #  NSFixedPitchFontSize = 15;
              #};
            };
          };

          # ── Login items & session environment ─────────────────────
          launchd.user = {
            # $XDG_RUNTIME_DIR
            # Tools that respect XDG_CACHE_HOME will move their caches from ~/Library/Caches to ~/.cache.
            # Time Machine skips ~/Library/Caches but backs up ~/.cache, so you'd be backing up
            # disposable data. Exclude it once:
            # sudo tmutil addexclusion ~/.cache
            envVariables = {
              XDG_CONFIG_HOME = "/Users/ben/.config";
              XDG_DATA_HOME = "/Users/ben/.local/share";
              XDG_STATE_HOME = "/Users/ben/.local/state";
              XDG_CACHE_HOME = "/Users/ben/.cache";
            };

            # Open these apps in the background at login
            agents.background-apps = {
              serviceConfig = {
                ProgramArguments = [
                  "/bin/sh"
                  "-c"
                  #"/usr/bin/open -gj -a Calendar; /usr/bin/open -gj -a Mail; /usr/bin/open -gj -a Messages; /usr/bin/open -gj -a Music; /usr/bin/open -gj -a Reminders"
                  "/usr/bin/open -gj -a Mail"
                ];
                RunAtLoad = true;
              };
            };

            # Open these apps at login, then hide them
            agents.hidden-apps = {
              serviceConfig = {
                # ScreenZen
                ProgramArguments = [
                  "/bin/sh"
                  "-c"
                  ''
                    apps="Claude"
                    for app in $apps; do /usr/bin/open -a "$app"; done
                    sleep 1
                    for app in $apps; do
                      /usr/bin/osascript -e "tell application \"System Events\" to set visible of process \"$app\" to false"
                    done
                  ''
                ];
                RunAtLoad = true;
              };
            };

            agents.reset-finder-views = {
              script = ''
                /usr/bin/find /Users/ben -path /Users/ben/Library -prune -o -name .DS_Store -type f -delete
                /usr/bin/killall Finder
              '';
              serviceConfig = {
                RunAtLoad = true; # run once at login
                StandardErrorPath = "/tmp/reset-finder-views.err";
              };
            };
          };

          # ── System services (run as root) ─────────────────────────
          # Sweep .DS_Store across the disk at boot and daily at 4am
          launchd.daemons.clean-ds-store = {
            script = ''
              /usr/bin/find /Users /Applications /Library -name .DS_Store -type f -delete
            '';
            serviceConfig = {
              RunAtLoad = true;
              StartCalendarInterval = [
                {
                  Hour = 4;
                  Minute = 0;
                }
              ];
              StandardErrorPath = "/var/log/clean-ds-store.err";
            };
          };

          environment.systemPath = [
            "/opt/homebrew/bin"
            "/Library/TeX/texbin"
            "/Users/ben/.local/bin/env"
          ];

          # ── Homebrew ──────────────────────────────────────────────
          homebrew = {
            enable = true;
            onActivation = {
              autoUpdate = true;
              upgrade = true;
              cleanup = "zap"; # WARNING: uninstalls AND zaps anything not listed below
            };

            taps = [
              {
                name = "benjaminchocolate/tap";
                trusted = true;
              }
              {
                name = "d12frosted/emacs-plus";
                clone_target = "https://github.com/d12frosted/homebrew-emacs-plus";
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

              # Emacs
              ## pdf-tools
              "pkg-config"
              "poppler"
              "autoconf"
              "automake"

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
                  "benjaminchocolate/tap/carla"
                  "benjaminchocolate/tap/moonlight@nightly"

                  # Hardware
                  "motu-m-series"
                  "keyboardcleantool"

                  # Creative: audio
                  "blackhole-2ch"
                  #"au-lab"
                  "bitwig-studio"
                  "surge-xt"
                  "mixxx"

                  # Creative: visual
                  "affinity"
                  #"touchdesigner"

                  # Development
                  "claude-code"
                  "d12frosted/emacs-plus/emacs-plus-app"
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
                  #"finetune"
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
        };

      # ==============================================================
      # USER (Home Manager): ben's dotfiles, shell, git, services
      # ==============================================================
      homeConfig =
        { pkgs, ... }:
        {
          home.stateVersion = "26.05";
          manual.manpages.enable = false;

          # ── XDG ───────────────────────────────────────────────────
          xdg.enable = true;
          home.preferXdgDirectories = true;

          # ── Packages ──────────────────────────────────────────────
          home.packages = with pkgs; [
            #bun
            #zsh-completions
          ];

          # ── Dotfiles ──────────────────────────────────────────────
          home.file.".clang-format".text = ''
            BasedOnStyle: Google
          '';
          home.file.".config/emacs-plus/build.yml".text = ''
            icon: liquid-glass
          '';
          # BreakBeforeBraces: Allman

          # ── Git ───────────────────────────────────────────────────
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
                email = "dev@benjamincarpenter.dev";
                signingkey = "/Users/ben/.ssh/id_ed25519.pub";
              };
              gpg.format = "ssh";
              commit.gpgsign = true;
              tag.gpgsign = true;
              init.defaultBranch = "main";
            };
          };

          # ── Shell ─────────────────────────────────────────────────
          home.shellAliases = {
            ls = "ls -la";
            rebuild = "sudo darwin-rebuild switch";
          };

          programs.zsh = {
            enable = true;
            # autosuggestion / syntaxHighlighting / historySubstringSearch lines removed:
            # Brew supplies those plugins now

            profileExtra = ''
              eval "$(/opt/homebrew/bin/brew shellenv)"
            '';

            # The one and only compinit, with zsh-completions added first
            completionInit = ''
              fpath=(/opt/homebrew/share/zsh-completions $fpath)
              autoload -Uz compinit && compinit
            '';

            initContent = ''
              # Completion: case-insensitive matching
              zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
              # Completion: menu you can move through with the arrow keys
              zstyle ':completion:*' menu select

              source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
              source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
              # history-substring-search must load AFTER syntax-highlighting (per its README)
              source /opt/homebrew/share/zsh-history-substring-search/zsh-history-substring-search.zsh
              bindkey '^[[A' history-substring-search-up    # up arrow
              bindkey '^[[B' history-substring-search-down  # down arrow

              eval "$(/opt/homebrew/bin/starship init zsh)"
            '';
          };

          # ── Services ──────────────────────────────────────────────

          # Emacs daemon (emacs-plus cask): starts at login, restarts if it dies
          launchd.agents.emacs-daemon = {
            enable = true;
            config = {
              ProgramArguments = [
                "/opt/homebrew/bin/emacs"
                "--fg-daemon"
              ];
              RunAtLoad = true; # start at login
              KeepAlive = true; # restart if it dies
              StandardOutPath = "/tmp/emacs-daemon.log";
              StandardErrorPath = "/tmp/emacs-daemon.log";
              # the cask doesn't inject your PATH, so tools like nixd need this
              EnvironmentVariables.PATH = "/etc/profiles/per-user/ben/bin:/run/current-system/sw/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin";
              ProcessType = "Interactive";
              Nice = -20; # Maybe a bad idea?
            };
          };
        };
    in
    {
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .#Benjamins-MacBook-Pro
      darwinConfigurations."Benjamins-MacBook-Pro" = nix-darwin.lib.darwinSystem {
        modules = [
          systemConfig
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.users.ben = homeConfig;
          }
        ];
      };
    };
}
