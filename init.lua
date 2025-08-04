-- FiveM Lua Library - Main Entry Point
-- Provides cleaner APIs using metatables
-- Supports both client and server-side usage

-- Side detection
local SERVER = IsDuplicityVersion()
local CLIENT = not SERVER

-- Get the Class function from the shared class.lua
local Class = _ENV.class

-- If Class is not available, load it from the shared script
if not Class then
  local classChunk = LoadResourceFile('fivem-lua-lib', 'shared/class.lua')
  if classChunk then
    local fn, err = load(classChunk, '@@jd-library/shared/class.lua')
    if fn then
      Class = fn()
      _ENV.class = Class
    else
      error("Error loading class system: " .. (err or "unknown error"))
    end
  else
    error("Class system not found. Make sure shared/class.lua exists.")
  end
end

-- Main library table
local fivem = {
  name = 'jd-library',
  context = SERVER and 'server' or 'client',
  Class = Class,
  isServer = SERVER,
  isClient = CLIENT
}

-- Make Class function globally available for other resources
_ENV.Class = Class

-- Make fivem table globally available
_ENV.fivem = fivem

return fivem