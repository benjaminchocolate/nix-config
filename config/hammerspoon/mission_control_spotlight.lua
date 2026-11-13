-- mission_control_spotlight.lua
-- 1. After you pick a window in Mission Control, macOS sometimes raises it
--    without giving it keyboard focus. On exit, focus the top window.
-- 2. Pressing the Spotlight shortcut inside Mission Control closes
--    Mission Control first, then opens Spotlight.

local ax  = require("hs.axuielement")
local log = hs.logger.new("mcFocus", "info")

local M = {}                 -- returned at the bottom; require() keeps it alive
local delay = 0.3            -- let the exit animation finish before checking focus
local spotlightDelay = 0.8   -- open Spotlight after the focus fix has had its turn
local SPOTLIGHT_MODS, SPOTLIGHT_KEY = {"cmd"}, "space"

local function topWindow()
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:isStandard() and win:isVisible() then return win end
  end
end

local function focusTopWindow()
  local top = topWindow()
  if not top then return end  -- e.g. you picked an empty Space

  local focused = hs.window.focusedWindow()
  if not focused or focused:id() ~= top:id() then
    top:focus()
  end
end

-- Mission Control's accessibility group (id "mc") only exists while it's on screen
local function missionControlOpen()
  local dock = hs.application.get("com.apple.dock")
  if not dock then return false end
  for _, child in ipairs(ax.applicationElement(dock)) do
    if child.AXIdentifier == "mc" then return true end
  end
  return false
end

M.tap = hs.eventtap.new({ hs.eventtap.event.types.keyDown }, function(e)
  if e:getKeyCode() ~= hs.keycodes.map[SPOTLIGHT_KEY]
     or not e:getFlags():containExactly(SPOTLIGHT_MODS) then
    return false                       -- not the Spotlight shortcut: pass through
  end

  local mcOpen = missionControlOpen()
  log.i("Cmd-Space seen, Mission Control open: " .. tostring(mcOpen))
  if not mcOpen then return false end  -- normal Cmd-Space: Spotlight handles it

  hs.spaces.closeMissionControl()
  M.spotlightTimer = hs.timer.doAfter(spotlightDelay, function()
    hs.eventtap.keyStroke(SPOTLIGHT_MODS, SPOTLIGHT_KEY)
  end)
  return true                          -- swallow the original press
end)
M.tap:start()

local function onDockEvent(_, _, notification)
  log.i("Dock event: " .. tostring(notification))  -- temporary
  if notification == "AXExposeExit" then
    M.pending = hs.timer.doAfter(delay, focusTopWindow)
  end
end

local function watchDock()
  local dock = hs.application.get("com.apple.dock")
  if not dock then return end

  if M.observer then M.observer:stop() end
  M.observer = ax.observer.new(dock:pid())
  M.observer:callback(onDockEvent)
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