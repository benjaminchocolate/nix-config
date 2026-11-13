-- Safari sidebar: open on big windows, hidden on split/small ones
local SIDEBAR_MIN_WIDTH = 0.6  -- fraction of screen width

local function updateSafariSidebar(win)
  -- Menu commands act on the focused window, so only touch that one
  if not win or win ~= hs.window.focusedWindow() then return end
  local screen = win:screen()
  if not screen then return end

  local ratio = win:frame().w / screen:frame().w
  local app = win:application()
  if ratio >= SIDEBAR_MIN_WIDTH then
    app:selectMenuItem({"View", "Show Sidebar"})
  else
    app:selectMenuItem({"View", "Hide Sidebar"})
  end
end

safariSidebarWatcher = hs.window.filter.new("Safari")
safariSidebarWatcher:subscribe(
  {
    hs.window.filter.windowCreated,
    hs.window.filter.windowFocused,
    hs.window.filter.windowMoved,          -- fires on move and resize
    hs.window.filter.windowFullscreened,
    hs.window.filter.windowUnfullscreened,
  },
  function(win) hs.timer.doAfter(0.2, function() updateSafariSidebar(win) end) end
)