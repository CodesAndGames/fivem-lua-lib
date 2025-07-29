-- FiveM Lua Library
-- Provides cleaner APIs using metatables
-- Supports both client and server-side usage

local FiveM = {}

-- Detect if we're running on server or client
local isServer = IsDuplicityVersion()
local isClient = not isServer

-- Class System (Shared)
local Class = {}
Class.__index = Class

-- Create a new class
function Class.new(name, parent)
  local cls = {}
  cls.__name = name
  cls.__parent = parent
  cls.__methods = {}
  cls.__static = {}
  cls.__private = {}
  
  -- Set up inheritance
  if parent then
    setmetatable(cls, {__index = parent})
    cls.__super = parent
  end
  
  -- Constructor
  cls.__init = function(self, ...)
    if parent and parent.__init then
      parent.__init(self, ...)
    end
  end
  
  -- Method to add methods to class
  function cls:method(name, func)
    self.__methods[name] = func
  end
  
  -- Method to add static methods
  function cls:static(name, func)
    self.__static[name] = func
  end
  
  -- Method to add private methods
  function cls:private(name, func)
    self.__private[name] = func
  end
  
  -- Constructor method (cleaner syntax)
  function cls:constructor(func)
    self.__init = func
  end
  
  -- Create instance
  function cls:new(...)
    local instance = {}
    instance.__class = cls
    instance.__name = cls.__name
    
    -- Copy methods
    for name, func in pairs(cls.__methods) do
      instance[name] = func
    end
    
    -- Copy static methods
    for name, func in pairs(cls.__static) do
      instance[name] = func
    end
    
    -- Set up inheritance chain
    if parent then
      setmetatable(instance, {__index = parent})
    end
    
    -- Call constructor
    if cls.__init then
      cls.__init(instance, ...)
    end
    
    return instance
  end
  
  -- Super method for calling parent methods
  function cls:super(...)
    if parent and parent.__init then
      return parent.__init(self, ...)
    end
  end
  
  -- Check if instance is of type
  function cls:isInstanceOf(class)
    local current = self.__class
    while current do
      if current == class then
        return true
      end
      current = current.__parent
    end
    return false
  end
  
  -- Get class name
  function cls:getClassName()
    return self.__name
  end
  
  -- Extend class
  function cls:extend(name)
    return Class.new(name, cls)
  end
  
  return cls
end

-- Create base class
function Class.create(name)
  return Class.new(name)
end

-- Events class (Shared)
local Events = Class.create("Events")

Events:method("on", function(self, eventName, callback)
  return AddEventHandler(eventName, callback)
end)

-- Removed mod method as ModifyEventHandler is not a valid native

Events:method("off", function(self, eventName)
  return RemoveEventHandler(eventName)
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

-- Players class (Client-only with server fallbacks)
local Players = Class.create("Players")

Players:method("get", function(self)
  if isClient then
    local ped = GetPlayerPed(PlayerId())
    if ped and ped ~= 0 then
      return ped
    else
      return nil
    end
  end
end)

Players:method("serverId", function(self)
  if isClient then
    return GetPlayerServerId(PlayerId())
  end
end)

Players:method("localId", function(self)
  if isClient then
    return PlayerId()
  end
end)

Players:method("pos", function(self)
  if isClient then
    local ped = GetPlayerPed(PlayerId())
    if ped and ped ~= 0 then
      return GetEntityCoords(ped)
    else
      return {x = 0, y = 0, z = 0}
    end
	end
end)

Players:method("tp", function(self, coords)
  if isClient then
    if not coords or not coords.x or not coords.y or not coords.z then
      print("Warning: Invalid coordinates provided for teleportation")
      return
    end
    
    local ped = GetPlayerPed(PlayerId())
    
    if ped and ped ~= 0 then
      SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
    else
      print("Warning: Invalid player ped for teleportation")
    end
  end
end)

Players:method("hp", function(self)
  if isClient then
    local ped = GetPlayerPed(PlayerId())
    if ped and ped ~= 0 then
      return GetEntityHealth(ped)
    else
      return "Couldn't get player health"
    end
  end
end)

Players:method("setHp", function(self, health)
  if isClient then
    local ped = GetPlayerPed(PlayerId())
    if ped and ped ~= 0 then
      SetEntityHealth(ped, health)
    else
      print("Warning: Invalid player ped for health setting")
    end
  end
end)

Players:method("name", function(self)
  if isClient then
    return GetPlayerName(PlayerId())
  else
	-- Server-side: Get player name by server ID
		return GetPlayerName(source)
  end
end)

-- Vehicles class (Client-only)
local Vehicles = Class.create("Vehicles")

Vehicles:method("get", function(self)
  if isClient then
    return GetVehiclePedIsIn(PlayerPedId(), false)
  end
end)

Vehicles:method("spawn", function(self, model, coords)
  if isClient then
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do
      Wait(0)
    end
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, false)
    SetModelAsNoLongerNeeded(hash)
    return vehicle
  end
end)

Vehicles:method("del", function(self, vehicle)
  if isClient then
    if DoesEntityExist(vehicle) then
      DeleteEntity(vehicle)
    end
  end
end)

Vehicles:method("pos", function(self, vehicle)
  if isClient then
    return GetEntityCoords(vehicle)
  end
end)

Vehicles:method("tp", function(self, vehicle, coords)
  if isClient then
    SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, true)
  end
end)

-- Utility class (Shared)
local Utils = Class.create("Utils")

-- Removed wait method as FiveM already has Wait() native
-- Removed print method as it's redundant with native print()

Utils:method("debug", function(self, ...)
  if Config and Config.debug then
    print("[DEBUG]", ...)
  end
end)

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
  local result = template:gsub("${([^}]+)}", function(key)
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
      return "${" .. key .. "}"
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

-- Command class (Shared)
local Command = Class.create("Command")

Command:method("reg", function(self, name, handler, restricted)
  return RegisterCommand(name, handler, restricted or false)
end)

Command:method("suggest", function(self, name, help, params)
  return TriggerEvent('chat:addSuggestion', name, help, params or {})
end)

Command:method("remove", function(self, name)
  return TriggerEvent('chat:removeSuggestion', name)
end)

-- KeyMapping class (Client-only)
local KeyMapping = Class.create("KeyMapping")

KeyMapping:method("reg", function(self, commandName, description, defaultMapper, defaultParameter)
  if isClient then
    return RegisterKeyMapping(commandName, description, defaultMapper or 'keyboard', defaultParameter or '')
  end
end)

KeyMapping:method("remove", function(self, commandName)
  if isClient then
    return TriggerEvent('chat:removeSuggestion', commandName)
  end
end)

-- Create instances
local events = Events:new()
local players = Players:new()
local vehicles = Vehicles:new()
local utils = Utils:new()
local command = Command:new()
local keyMapping = KeyMapping:new()

-- Assign instances to main table
FiveM.events = events
FiveM.players = players
FiveM.vehicles = vehicles
FiveM.utils = utils
FiveM.command = command
FiveM.keyMapping = keyMapping
FiveM.Class = Class

-- Add environment detection
FiveM.isServer = isServer
FiveM.isClient = isClient

-- Global access
_G.fivem = FiveM
_G.Class = Class
_G.events = events
_G.players = players
_G.vehicles = vehicles
_G.utils = utils
_G.command = command
_G.keyMapping = keyMapping

-- Add client-side event handler for server teleport requests (if needed for server-side teleportation)
if isClient then
  AddEventHandler('fivem:teleportPlayer', function(coords)
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, true)
  end)
end

return FiveM