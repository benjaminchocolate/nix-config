-- mission_control_scroll.lua
-- In Mission Control, the mouse wheel switches desktops (like a 3-finger swipe).
-- Everywhere else, scrolling is left alone.
--
-- Install: put this file next to your init.lua, then add to init.lua:
--     require("mission_control_scroll")
-- Undo:    remove that line and reload, or in the console:
--     require("mission_control_scroll").tap:stop()

local M = {}

-- Settings ------------------------------------------------------------------
M.invert   = false  -- flip to true if the scroll direction feels backwards
M.cooldown = 0.35   -- seconds to ignore the wheel after a switch (animation time)

-- Mission Control detection -------------------------------------------------
-- While Mission Control is open, the Dock process exposes an accessibility
-- group whose identifier is "mc". hs.spaces uses this same check internally.
local dock = nil

local function dockElement()
  if not (dock and dock:isValid()) then -- first run, or the Dock restarted
    local app = hs.application.applicationsForBundleID("com.apple.dock")[1]
    if not app then return nil end
    dock = hs.axuielement.applicationElement(app)
    dock:setTimeout(0.1) -- a busy Dock can't stall your scrolling for long
  end
  return dock
end

local function missionControlOpen()
  local d = dockElement()
  if not d then return false end
  for _, child in ipairs(d:attributeValue("AXChildren") or {}) do
    if child:attributeValue("AXIdentifier") == "mc" then return true end
  end
  return false
end

M.missionControlOpen = missionControlOpen -- exposed so you can test it

-- Wheel -> desktop switch ---------------------------------------------------
local props = hs.eventtap.event.properties
local lastSwitch = -math.huge -- "never switched yet"

-- Turn one wheel event into "left", "right", or nil (do nothing).
-- Rule: one switch, then ignore the wheel until the cooldown passes.
-- Keep scrolling and it steps one desktop per cooldown.
local function directionFor(delta)
  local now = hs.timer.secondsSinceEpoch()
  if delta == 0 or now - lastSwitch < M.cooldown then return nil end
  lastSwitch = now
  if M.invert then delta = -delta end
  return (delta < 0) and "right" or "left"
end

M.tap = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(e)
  -- Trackpad scrolls carry a gesture phase; plain mouse wheels don't.
  -- Leave the trackpad alone so 2-finger scrolling in Mission Control is untouched.
  if e:getProperty(props.scrollWheelEventScrollPhase) ~= 0
    or e:getProperty(props.scrollWheelEventMomentumPhase) ~= 0 then
    return false
  end

  if not missionControlOpen() then
    return false -- false = pass the scroll through untouched
  end

  local dir = directionFor(e:getProperty(props.scrollWheelEventDeltaAxis1))
  if dir then
    -- Real arrow keys carry the fn flag; without it macOS ignores a
    -- synthetic ctrl+arrow for space switching. Delay 0 = don't block.
    hs.eventtap.keyStroke({ "ctrl", "fn" }, dir, 0)
  end
  return true -- true = swallow the scroll so Mission Control never sees it
end):start()

return M