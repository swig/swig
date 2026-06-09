local v=require("union_parameter")

local event = v.SDL_Event()
for i=1,4 do -- Run twice each event
  assert(v.SDL_PollEvent(event) == 1)
  local eventUnionType = event.type
  local eventTypeInStruct = 0
  if eventUnionType == 1 then
    local activeEvent = event.active
    assert(activeEvent.gain == 20)
    assert(activeEvent.state == 30)
    eventTypeInStruct = activeEvent.type
  elseif eventUnionType == 2 then
    local keyEvent = event.key
    assert(keyEvent.which == 2000)
    assert(keyEvent.state == 3000)
    eventTypeInStruct = keyEvent.type
  else
    assert(false, "wrong value of eventUnionType=" .. eventUnionType)
  end
  assert(eventTypeInStruct == eventUnionType)
end
