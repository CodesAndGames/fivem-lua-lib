-- KeyMapping class (Client-only)
local KeyMap = class("KeyMap")

KeyMap:method("reg", function(self, commandName, description, defaultMapper, defaultParameter)
  return RegisterKeyMapping(commandName, description, defaultMapper or 'keyboard', defaultParameter or '')
end)

-- Create instance
local keyMap = KeyMap:new()

-- Make KeyMapping instance globally available (client-side)
_ENV.keyMap = keyMap

return KeyMap