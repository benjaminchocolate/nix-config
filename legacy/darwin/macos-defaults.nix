{ config, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true;
      AppleWindowTabbingMode = "always";
      InitialKeyRepeat = 25; # in 15 ms units
      KeyRepeat = 2; # fastest the slider allows
      "com.apple.trackpad.scaling" = 1.0;
    };

    dock = {
      autohide = true;
      largesize = 68;
      magnification = true;
      mineffect = "genie";
      orientation = "bottom";
      show-recents = false;
      tilesize = 64;

      showAppExposeGestureEnabled = true;
      showMissionControlGestureEnabled = true;

      # Hot corners: 2 = Mission Control, 3 = Application Windows
      wvous-bl-corner = 3;
      wvous-br-corner = 3;
      wvous-tl-corner = 2;
      wvous-tr-corner = 2;
    };

    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXDefaultSearchScope = "SCcf"; # search the current folder
      FXEnableExtensionChangeWarning = false;
      FXPreferredViewStyle = "Nlsv"; # list view
      FXRemoveOldTrashItems = true; # after 30 days
      NewWindowTarget = "Home";
      ShowPathbar = true;
      ShowStatusBar = true;
      _FXShowPosixPathInTitle = true;
      _FXSortFoldersFirst = true;

      CreateDesktop = true; # false also removes desktop right-click and drag-select
      ShowExternalHardDrivesOnDesktop = false;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = false;
    };

    screencapture = {
      disable-shadow = true;
      include-date = true;
      location = "${home}/Desktop/Screenshots";
      show-thumbnail = true;
      target = "clipboard";
      type = "png";
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDate = 1; # 0 = when space allows, 1 = always, 2 = never
      ShowDayOfWeek = true;
    };

    WindowManager = {
      GloballyEnabled = false; # Stage Manager
      EnableStandardClickToShowDesktop = true;
      EnableTiledWindowMargins = false;
      HideDesktop = true;
      StageManagerHideWidgets = true;
      StandardHideDesktopIcons = true;
      StandardHideWidgets = true;
    };

    # Settings without a nix-darwin option (`defaults write <domain> <key>`)
    CustomUserPreferences = {
      NSGlobalDomain = {
        AppleActionOnDoubleClick = "Fill"; # double-clicking a title bar
        AppleMenuBarVisibleInFullscreen = true;
        "com.apple.scrollwheel.scaling" = 0.3125;

        # new
        NSFont = "AtkinsonHyperlegibleNext-Regular";
        NSFontSize = 15;
        NSFixedPitchFont = "AtkinsonHyperlegibleMono-Regular";
        NSFixedPitchFontSize = 15;
      };

      "com.apple.desktopservices" = {
        DSDontWriteNetworkStores = true;
        DSDontWriteUSBStores = true;
      };

      "com.apple.finder"._FXEnableColumnAutoSizing = true;

      "com.apple.TextEdit".RichText = false;

      "com.apple.Safari" = {
        IncludeDevelopMenu = true;
        WebKitDeveloperExtrasEnabledPreferenceKey = true;
        "com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled" = true;
        WebKitExperimentalPreferPageRenderingUpdatesNear60FPSEnabled = false;
      };

      "org.hammerspoon.Hammerspoon".MJConfigFile = "~/.config/hammerspoon/init.lua";
    };
  };
}
