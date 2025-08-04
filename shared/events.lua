-- Events class (Shared)
local Events = class("Events")

-- Track registered network events
Events.netEvents = {}

Events:method("on", function(self, eventName, callback)
  -- Auto-register as network event for all events
  if not self.netEvents[eventName] then
    RegisterNetEvent(eventName)
    self.netEvents[eventName] = true
  end
  return AddEventHandler(eventName, callback)
end)

Events:method("emit", function(self, eventName, ...)
  return TriggerEvent(eventName, ...)
end)

Events:method("emitServer", function(self, eventName, ...)
  return TriggerServerEvent(eventName, ...)
end)

Events:method("emitClient", function(self, eventName, target, ...)
  return TriggerClientEvent(eventName, target, ...)
end)

-- Create instance
local events = Events:new()

-- Make Events class and instance globally available
_ENV.events = events

return Events