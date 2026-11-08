# macOS defaults: Dock, Finder, screenshots, Stage Manager, per-app prefs
{
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
}
