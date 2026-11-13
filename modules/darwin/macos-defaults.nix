# macOS defaults: Dock, Finder, screenshots, Stage Manager, per-app prefs
{ config, ... }:
let
  home = config.users.users.${config.system.primaryUser}.home;
in
{
  system.defaults = {
    # Keyboard, appearance and pointer settings from System Settings
    NSGlobalDomain = {
      AppleInterfaceStyleSwitchesAutomatically = true; # Appearance: Auto
      AppleWindowTabbingMode = "always"; # prefer tabs when opening documents
      InitialKeyRepeat = 25; # delay before a held key repeats (15 ms units)
      KeyRepeat = 2; # repeat rate: the fastest the slider goes
      "com.apple.trackpad.scaling" = 1.0; # trackpad tracking speed
    };

    dock = {
      orientation = "bottom";
      mineffect = "genie";
      tilesize = 64; # normal icon size in pixels (16–128)
      magnification = true; # enlarge icons on hover
      largesize = 72; # magnified size in pixels (16–128)
      autohide = true;
      show-recents = false;

      # Hot corners: 2 = Mission Control, 3 = Application Windows
      wvous-tl-corner = 2;
      wvous-tr-corner = 2;
      wvous-bl-corner = 3;
      wvous-br-corner = 3;

      # Trackpad swipe gestures for the same two views
      showMissionControlGestureEnabled = true;
      showAppExposeGestureEnabled = true;
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
      FXRemoveOldTrashItems = true; # empty Trash items after 30 days
      AppleShowAllFiles = true;
    };

    screencapture = {
      disable-shadow = true;
      include-date = true;
      location = "${home}/Pictures/Screenshots";
      show-thumbnail = true;
      type = "png";
      target = "clipboard"; # screenshots go to the clipboard, not a file
    };

    menuExtraClock = {
      ShowAMPM = true;
      ShowDayOfWeek = true;
      ShowDate = 1; # 0 = when space allows, 1 = always, 2 = never
    };

    WindowManager = {
      GloballyEnabled = false; # Stage Manager off
      StandardHideDesktopIcons = true; # hide desktop files
      StandardHideWidgets = true; # hide desktop widgets
      StageManagerHideWidgets = true; # hide them if Stage Manager ever gets turned on
      EnableStandardClickToShowDesktop = false;
      EnableTiledWindowMargins = false; # no gaps between tiled windows
      HideDesktop = true; # Stage Manager: hide desktop items
    };

    # Per-app preferences: same as `defaults write <domain> <key> <value>`
    CustomUserPreferences = {
      # Settings nix-darwin has no named option for
      NSGlobalDomain = {
        AppleActionOnDoubleClick = "Fill"; # double-click a title bar to fill the screen
        AppleMenuBarVisibleInFullscreen = true;
        "com.apple.scrollwheel.scaling" = 0.3125; # mouse wheel speed
      };

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

      # System-wide UI font (disabled). To try it again, add these to the
      # NSGlobalDomain block above:
      #   NSFont = "Atkinson Hyperlegible Next";
      #   NSFontSize = 15;
      #   NSFixedPitchFont = "Atkinson Hyperlegible Mono";
      #   NSFixedPitchFontSize = 15;
    };
  };
}
