-- Commands class (Shared)
local Commands = class("Commands")

Commands:method("reg", function(self, name, handler, restricted)
  return RegisterCommand(name, handler, restricted or false)
end)

Commands:method("suggest", function(self, name, help, params)
  return TriggerEvent('chat:addSuggestion', name, help, params or {})
end)

Commands:method("remove", function(self, name)
  return TriggerEvent('chat:removeSuggestion', name)
end)

-- Create instance
local commands = Commands:new()

-- Make Commands class and instance globally available
_ENV.commands = commands

return Commands 