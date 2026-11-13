-- Hammerspoon entry point. Each require() loads one file from this directory.
-- This directory is a link to config/hammerspoon in the dotfiles repo:
-- edit, then reload Hammerspoon (menu bar icon, or hs.reload() in the console).

-- Mission Control
require("mission_control_focus")
require("mission_control_spotlight")
require("mission_control_scroll")

-- Windows
require("focus_after_close")
require("green_button_fill")
-- require("green_button_fill_experiment")

-- Safari
safariTabScroll = require("safari_tab_scroll")
-- require("safari_sidebar")

-- Mouse
require("mouse_side_buttons")
