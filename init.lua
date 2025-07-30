-- FiveM Lua Library - Main Entry Point
-- Provides cleaner APIs using metatables
-- Supports both client and server-side usage

-- Side detection
local SERVER = IsDuplicityVersion()
local CLIENT = not SERVER

-- Module loading system
local modules = {}

local function module(rsc, path)
  if not path then -- shortcut for jd-library, can omit the resource parameter
    path = rsc
    rsc = "jd-library"
  end
  local key = rsc.."/"..path
  local rets = modules[key]
  if rets then -- cached module
    return table.unpack(rets, 2, rets.n)
  else
    local code = LoadResourceFile(rsc, path..".lua")
    if code then
      local f, err = load(code, rsc.."/"..path..".lua")
      if f then
        local rets = table.pack(xpcall(f, debug.traceback))
        if rets[1] then
          modules[key] = rets
          return table.unpack(rets, 2, rets.n)
        else
          error("error loading module "..rsc.."/"..path..": "..rets[2])
        end
      else
        error("error parsing module "..rsc.."/"..path..": "..err)
      end
    else
      error("resource file "..rsc.."/"..path..".lua not found")
    end
  end
end

-- Load required classes
local Class = module("jd-library", "shared/class")
local Events = module("jd-library", "shared/events")
local Utils = module("jd-library", "shared/utils")
local Commands = module("jd-library", "shared/commands")

-- Detect if we're running on server or client
local isServer = IsDuplicityVersion()
local isClient = not isServer

-- Create instances from the loaded classes (shared)
local events = Events:new()
local utils = Utils:new()
local commands = Commands:new()

-- Create environment-specific instances
local players = nil
local vehicles = nil
local keyMapping = nil

if isClient then
  -- Client-specific instances
  local Players = module("jd-library", "client/players")
  local Vehicles = module("jd-library", "client/vehicles")
  local KeyMapping = module("jd-library", "client/keymapping")
  
  players = Players:new()
  vehicles = Vehicles:new()
  keyMapping = KeyMapping:new()
elseif isServer then
  -- Server-specific instances
  local Players = module("jd-library", "server/players")
  players = Players:new()
end

-- Main FiveM table
local FiveM = {}

-- Assign instances to main table
FiveM.events = events
FiveM.players = players
FiveM.vehicles = vehicles
FiveM.utils = utils
FiveM.commands = commands
FiveM.keyMapping = keyMapping
FiveM.Class = Class

-- Add environment detection
FiveM.isServer = isServer
FiveM.isClient = isClient

-- Global access
_G.fivem = FiveM
_G.events = events
_G.players = players
_G.vehicles = vehicles
_G.utils = utils
_G.commands = commands
_G.keyMapping = keyMapping

return FiveM
