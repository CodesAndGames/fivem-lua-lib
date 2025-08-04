-- Detect if we're running on server or client
local isServer = IsDuplicityVersion()
local isClient = not isServer

-- Utility class (Shared)
local Utils = class("Utils")

Utils:method("dist", function(self, pos1, pos2)
  if type(pos1) == "vector3" and type(pos2) == "vector3" then
    return #(pos1 - pos2)
  elseif pos1.x and pos1.y and pos1.z and pos2.x and pos2.y and pos2.z then
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    local dz = pos1.z - pos2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
  else
    return 0
  end
end)

Utils:method("round", function(self, num, decimals)
  local mult = 10^(decimals or 0)
  return math.floor(num * mult + 0.5) / mult
end)

Utils:method("print", function(self, template, ...)
  local args = {...}
  local result = template:gsub("{(%d+)}", function(index)
    return tostring(args[tonumber(index)] or "")
  end)
  return print(result)
end)

Utils:method("tmpl", function(self, template, ...)
  local args = {...}
  local result = template:gsub("{([^}]+)}", function(key)
    local index = tonumber(key)
    if index then
      return tostring(args[index] or "")
    else
      -- Try to find the variable in the calling scope
      local level = 2
      while level <= 10 do
        local info = debug.getinfo(level, "S")
        if not info then break end
        
        local i = 1
        while true do
          local name, val = debug.getlocal(level, i)
          if not name then break end
          if name == key then
            return tostring(val or "")
          end
          i = i + 1
        end
        level = level + 1
      end
      return "{" .. key .. "}"
    end
  end)
  return result
end)

Utils:method("server", function(self)
  return isServer
end)

Utils:method("client", function(self)
  return isClient
end)

-- Create instance
local utils = Utils:new()

-- Make Utils class and instance globally available
_ENV.utils = utils

return Utils 