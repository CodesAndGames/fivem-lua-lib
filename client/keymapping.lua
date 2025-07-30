-- KeyMapping class (Client-only)
local KeyMapping = class("KeyMapping")

KeyMapping:method("reg", function(self, commandName, description, defaultMapper, defaultParameter)
  return RegisterKeyMapping(commandName, description, defaultMapper or 'keyboard', defaultParameter or '')
end)

-- Make KeyMapping globally available
_G.KeyMapping = KeyMapping

return KeyMapping 