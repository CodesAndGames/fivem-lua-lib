-- Events class (Shared)
local Events = class("Events")

Events:method("on", function(self, eventName, callback)
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

-- Make Events globally available
_G.Events = Events

return Events 