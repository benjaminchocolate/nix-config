-- focus_after_close.lua
-- When you close the last window of the frontmost app, macOS leaves that
-- (now windowless) app focused. This focuses the next window in the stack instead.

local delay = 0.15   -- give macOS a moment to settle focus on its own first
local pending = nil  -- keep a reference so the timer isn't garbage-collected

local function focusNextWindow(closedAppName)
  local front = hs.application.frontmostApplication()

  -- macOS already switched apps (e.g. the app quit): nothing to do
  if not front or front:name() ~= closedAppName then return end

  -- The app still has another window focused: macOS handled it
  if front:focusedWindow() then return end

  -- Otherwise focus the topmost normal, visible window on screen
  for _, win in ipairs(hs.window.orderedWindows()) do
    if win:isStandard() and win:isVisible() then
      win:focus()
      return
    end
  end
end

hs.window.filter.default:subscribe(hs.window.filter.windowDestroyed, function(_, appName)
  pending = hs.timer.doAfter(delay, function() focusNextWindow(appName) end)
end)