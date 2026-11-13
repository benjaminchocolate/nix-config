local BACK, FWD = 3, 4

sideButtons = hs.eventtap.new({hs.eventtap.event.types.otherMouseDown}, function(e)
  local btn = e:getProperty(hs.eventtap.event.properties.mouseEventButtonNumber)
  local dir = (btn == BACK and "Left") or (btn == FWD and "Right")
  if not dir then return false end
  hs.eventtap.event.newGesture("beginSwipe" .. dir):post()
  hs.eventtap.event.newGesture("endSwipe" .. dir):post()
  return true
end):start()