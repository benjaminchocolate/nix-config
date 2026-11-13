-- Green button: plain click acts like ⌥-click (native Fill)
local types = hs.eventtap.event.types
local onGreen = false

local function isGreenButton(pos)
  local el = hs.axuielement.systemElementAtPosition(pos)
  return el ~= nil and el:attributeValue("AXSubrole") == "AXFullScreenButton"
end

greenTap = hs.eventtap.new({ types.leftMouseDown, types.leftMouseUp }, function(e)
  local f = e:getFlags()
  if f.alt or f.cmd or f.ctrl or f.shift then return false end -- leave modified clicks alone

  if e:getType() == types.leftMouseDown then
    onGreen = isGreenButton(e:location())
  end
  if onGreen then
    e:setFlags({ alt = true })
    if e:getType() == types.leftMouseUp then onGreen = false end
  end
  return false -- pass the (edited) event through
end)
greenTap:start()