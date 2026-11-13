-- mission_control_focus.lua
-- After you pick a window in Mission Control, macOS sometimes raises it
-- without giving it keyboard focus. This listens for Mission Control closing
-- (the Dock's AXExposeExit accessibility notification) and focuses the top window.

local ax = require("hs.axuielement")

local M = {}          -- returned at the bottom; require() keeps it alive,
                      -- which stops the observer and watchers being garbage-collected
local delay = 0.3     -- let the exit animation finish before checking focus

local function topWindow()
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:isStandard() and win:isVisible() then return win end
  end
end

local function focusTopWindow()
  local top = topWindow()
  if not top then return end  -- e.g. you picked an empty Space

  local focused = hs.window.focusedWindow()
  -- Only act when the raised window and the focused window disagree
  if not focused or focused:id() ~= top:id() then
    top:focus()
  end
end

local function watchDock()
  local dock = hs.application.get("com.apple.dock")
  if not dock then return end

  if M.observer then M.observer:stop() end
  M.observer = ax.observer.new(dock:pid())
  M.observer:callback(function()
    M.pending = hs.timer.doAfter(delay, focusTopWindow)
  end)
  M.observer:addWatcher(ax.applicationElement(dock), "AXExposeExit")
  M.observer:start()
end

watchDock()

-- If the Dock restarts (e.g. `killall Dock`), re-attach to the new process
M.dockWatcher = hs.application.watcher.new(function(_, event, app)
  if event == hs.application.watcher.launched
     and app and app:bundleID() == "com.apple.dock" then
    hs.timer.doAfter(1, watchDock)
  end
end)
M.dockWatcher:start()

return M