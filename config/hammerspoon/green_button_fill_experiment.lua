-- green_button_fill_experiment.lua (v6): green button -> native Fill by holding a synthetic Option key
-- Load:  dofile(hs.configdir .. "/green_button_fill_experiment.lua")
-- Stop:  greenTest:stop()   (or Reload Config)
-- Option feels stuck? Press and release your physical Option key once.

if greenTap then greenTap:stop() end
if greenTest then greenTest:stop() end

local types = hs.eventtap.event.types
local props = hs.eventtap.event.properties
local GREEN = { AXFullScreenButton = true, AXZoomButton = true }
local MARK  = 0x67726e      -- tag on clicks we post ourselves
local optHeld = false
local pending = nil         -- the click we've taken over: { downSent, up }

local function option(down)
  hs.eventtap.event.newKeyEvent(hs.keycodes.map.alt, down):post()
  optHeld = down
end

local function marked(ev)                  -- copy of a click, with ⌥ and our tag
  ev:setFlags({ alt = true })
  ev:setProperty(props.eventSourceUserData, MARK)
  return ev
end

local function finish()
  pending = nil
  hs.timer.doAfter(0.02, function() option(false) end)
end

greenTest = hs.eventtap.new({ types.leftMouseDown, types.leftMouseUp }, function(e)
  if e:getProperty(props.eventSourceUserData) == MARK then return false end  -- our replay

  -- release half of a click we took over: swallow it and replay it in order
  if e:getType() == types.leftMouseUp then
    if not pending then return false end
    local up = marked(e:copy())
    if pending.downSent then up:post(); finish()
    else pending.up = up end               -- fast tap: send right after the press
    return true
  end

  local f = e:getFlags()
  if f.alt or f.cmd or f.ctrl or f.shift then return false end  -- real modifiers: stock

  local el  = hs.axuielement.systemElementAtPosition(e:location())
  local sub = el and el:attributeValue("AXSubrole")
  if not GREEN[sub] then return false end

  local spaceID = hs.spaces.activeSpaceOnScreen(hs.mouse.getCurrentScreen())
  local kind = spaceID and hs.spaces.spaceType(spaceID)
  print(string.format("green: %-18s space=%s", sub, tostring(kind)))
  if kind == "fullscreen" then return false end  -- exiting fullscreen: stock

  -- hold Option, wait a beat, then replay this press with Option down
  option(true)
  local down = marked(e:copy())
  local p = { downSent = false }
  pending = p
  hs.timer.doAfter(0.02, function()
    down:post(); p.downSent = true
    if p.up then p.up:post(); finish() end
  end)
  hs.timer.doAfter(3, function() if optHeld then option(false) end end)  -- safety release
  return true
end):start()