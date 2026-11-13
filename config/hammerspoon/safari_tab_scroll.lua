-- safari_tab_scroll.lua
-- Scroll Safari's tab bar sideways with a normal mouse wheel (no Shift needed).
--
-- Load it from init.lua with:
--   safariTabScroll = require("safari_tab_scroll")
--
-- Console helpers:
--   safariTabScroll.debug()     -- hover the tab bar within 3 s, prints what's under the cursor
--   safariTabScroll.tap:stop()  -- turn it off until the next reload

local M = {}

local SAFARI   = "com.apple.Safari"
local TOP_BAND = 150  -- px from the top of the Safari window that can hold the tab bar

local props = hs.eventtap.event.properties
local types = hs.eventtap.event.types

-- Precondition: eventtaps and accessibility queries both need this permission.
if not hs.accessibilityState() then
  hs.alert.show("Safari tab scroll: give Hammerspoon Accessibility access")
end

-- Is the cursor over Safari's tab bar?
local function overSafariTabBar(pos)
  -- 1. Cheap checks first: Safari in front, cursor near the top of its window.
  local app = hs.application.frontmostApplication()
  if not app or app:bundleID() ~= SAFARI then return false end

  local win = hs.window.focusedWindow()
  if not win then return false end
  local f = win:frame()
  if pos.x < f.x or pos.x > f.x + f.w or pos.y < f.y or pos.y > f.y + TOP_BAND then
    return false
  end

  -- 2. Precise check: walk up from the element under the cursor.
  --    Safari's tab bar (from debug): AXRadioButton -> AXOpaqueProviderGroup -> AXWindow.
  --    A radio button inside a web page has an AXWebArea in between, so reject that.
  local el = hs.axuielement.systemElementAtPosition(pos)
  local sawTab = false
  for _ = 1, 8 do
    if not el then return false end
    local role = el:attributeValue("AXRole")
    if role == "AXRadioButton" then sawTab = true end
    if role == "AXWebArea" then return false end
    if role == "AXWindow" then return sawTab end
    el = el:attributeValue("AXParent")
  end
  return false
end

M.tap = hs.eventtap.new({ types.scrollWheel }, function(e)
  -- Only plain wheel scrolls. Trackpads and Magic Mouse already scroll sideways.
  if e:getProperty(props.scrollWheelEventIsContinuous) ~= 0 then return false end

  local dy = e:getProperty(props.scrollWheelEventDeltaAxis1)  -- vertical, in lines
  local dx = e:getProperty(props.scrollWheelEventDeltaAxis2)  -- horizontal
  if dy == 0 or dx ~= 0 then return false end  -- nothing to convert (also prevents loops)

  local pos = hs.mouse.absolutePosition()
  if not overSafariTabBar(pos) then return false end

  -- newScrollEvent takes {horizontal, vertical}. Flip to -dy if it feels backwards.
  local sideways = hs.eventtap.event.newScrollEvent({ dy, 0 }, {}, "line")
  sideways:location(pos)
  return true, { sideways }  -- delete the vertical scroll, post a sideways one
end)

M.tap:start()

-- Prints the accessibility roles under the cursor, plus how far it is from the
-- top of the Safari window (to tune TOP_BAND).
function M.debug()
  print("Hover over Safari's tab bar...")
  hs.timer.doAfter(3, function()
    local pos = hs.mouse.absolutePosition()
    local el = hs.axuielement.systemElementAtPosition(pos)
    for i = 1, 8 do
      if not el then break end
      print(i, el:attributeValue("AXRole"))
      el = el:attributeValue("AXParent")
    end
    local safari = hs.application.get(SAFARI)
    local win = safari and safari:focusedWindow()
    if win then
      print("px from top of Safari window:", math.floor(pos.y - win:frame().y))
    end
  end)
end

return M
