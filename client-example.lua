-- Client-Side Example using FiveM Library
-- This file demonstrates client-side functionality only

-- Do note that if you are having errors, try assigning the library to a variable.
-- For example: local fivem = require('fivem-library')
-- This will allow you to use the library in your script wuth the fivem.* prefix.

-- Wait for the library to load
Citizen.CreateThread(function()
    while not fivem do
        Citizen.Wait(100)
    end
    
    print('FiveM Library loaded on client!')
    startClientExample()
end)

function startClientExample()
    -- ========================================
    -- EVENTS EXAMPLES (Client-Side)
    -- ========================================
    
    -- Listen for player spawn
events:on('playerSpawned', function()
  print('Player spawned! Setting up client...')
  
  -- Set player health and armor
  players:setHp(200)
  SetPedArmour(players:get(), 100)
  
  -- Teleport to spawn location
  players:tp({x = -1037.74, y = -2738.04, z = 20.17})
  
  -- Notify server that player is ready
  events:emitServer('playerReady')
end)
    
    -- Listen for custom events from server
events:on('serverMessage', function(message)
  print('Server says:', message)
end)

-- Listen for vehicle spawn requests
events:on('spawnVehicle', function(model)
  local playerCoords = players:pos()
  local vehicle = vehicles:spawn(model, playerCoords)
  
  if vehicle ~= 0 then
    -- Put player in vehicle
    SetPedIntoVehicle(players:get(), vehicle, -1)
    print('Vehicle spawned:', model)
    
    -- Notify server
    events:emitServer('vehicleSpawned', model)
  else
    print('Failed to spawn vehicle:', model)
  end
end)
    
    -- ========================================
    -- PLAYER EXAMPLES (Client-Side)
    -- ========================================
    
    -- Monitor player health
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000) -- Check every 5 seconds
    
    local health = players:hp()
    local coords = players:pos()
    
    -- Low health warning
    if health < 50 then
      print('Warning: Low health! Current health:', health)
      events:emitServer('lowHealthWarning', health)
    end
    
    -- Log position every 30 seconds
    if GetGameTimer() % 30000 < 5000 then
      print('Current position:', coords.x, coords.y, coords.z)
    end
  end
end)
    
    -- ========================================
    -- VEHICLE EXAMPLES (Client-Side Only)
    -- ========================================
    
    -- Monitor current vehicle
Citizen.CreateThread(function()
  while true do
    Citizen.Wait(2000)
    
    local vehicle = vehicles:get()
    if vehicle ~= 0 then
      local vehicleCoords = vehicles:pos(vehicle)
      local speed = GetEntitySpeed(vehicle) * 3.6 -- km/h
      
      -- Log vehicle info
      print('In vehicle - Speed:', math.floor(speed), 'km/h')
      print('Vehicle position:', vehicleCoords.x, vehicleCoords.y, vehicleCoords.z)
      
      -- Check vehicle health
      local health = GetVehicleEngineHealth(vehicle)
      if health < 500 then
        print('Warning: Vehicle engine health low!')
      end
    end
  end
end)
    
    -- ========================================
    -- UTILITIES EXAMPLES (Client-Side)
    -- ========================================
    
    -- Distance calculation example
local function checkDistanceToTarget(targetCoords)
  local playerCoords = players:pos()
  local distance = utils:dist(playerCoords, targetCoords)
  
  if distance < 10 then
    print('Close to target! Distance:', utils:round(distance, 2), 'units')
    return true
  end
  
  return false
end

-- Template string example
local function createStatusMessage()
  local health = players:hp()
  local coords = players:pos()
  local vehicle = vehicles:get()
  
  local message = utils:tmpl('Health: ${health} | Position: ${x}, ${y}, ${z} | In Vehicle: ${inVehicle}', 
    health, coords.x, coords.y, coords.z, vehicle ~= 0 and 'Yes' or 'No')
  
  print(message)
  return message
end
    
    -- ========================================
    -- CLASS SYSTEM EXAMPLES (Client-Side)
    -- ========================================
    
    -- Create a Player class for client-side use
    local ClientPlayer = Class.create("ClientPlayer")
    
    ClientPlayer:constructor(function(self)
        self.lastPosition = players.pos()
        self.healthHistory = {}
        self.vehicleHistory = {}
    end)
    
    ClientPlayer:method("updatePosition", function(self)
  local currentPos = players:pos()
  local distance = utils:dist(self.lastPosition, currentPos)
  
  if distance > 100 then
    print('Player moved', utils:round(distance, 2), 'units')
  end
  
  self.lastPosition = currentPos
end)

ClientPlayer:method("addHealthRecord", function(self)
  local health = players:hp()
  table.insert(self.healthHistory, {
    health = health,
    timestamp = GetGameTimer()
  })
  
  -- Keep only last 10 records
  if #self.healthHistory > 10 then
    table.remove(self.healthHistory, 1)
  end
end)

ClientPlayer:method("getAverageHealth", function(self)
  if #self.healthHistory == 0 then
    return 0
  end
  
  local total = 0
  for _, record in ipairs(self.healthHistory) do
    total = total + record.health
  end
  
  return utils:round(total / #self.healthHistory, 0)
end)
    
    -- Create player instance
    local clientPlayer = ClientPlayer:new()
    
    -- Update player data every 10 seconds
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(10000)
            
            clientPlayer:updatePosition()
            clientPlayer:addHealthRecord()
            
            local avgHealth = clientPlayer:getAverageHealth()
            print('Average health over time:', avgHealth)
        end
    end)
    
    -- ========================================
    -- COMMAND EXAMPLES (Client-Side)
    -- ========================================
    
    -- Register client commands
commands:reg('heal', function()
  players:setHp(200)
  print('Player healed!')
end, false)

commands:reg('tp', function(source, args)
  if #args >= 3 then
    local x = tonumber(args[1])
    local y = tonumber(args[2])
    local z = tonumber(args[3])
    
    if x and y and z then
      players:tp({x = x, y = y, z = z})
      print('Teleported to:', x, y, z)
    else
      print('Invalid coordinates!')
    end
  else
    print('Usage: /tp <x> <y> <z>')
  end
end, false)

commands:reg('car', function(source, args)
  if #args >= 1 then
    local model = args[1]
    events:emit('spawnVehicle', model)
  else
    print('Usage: /car <model>')
  end
end, false)
    
    RegisterCommand('status', function()
        createStatusMessage()
    end, false)
    
    -- ========================================
    -- KEY BINDING EXAMPLES (Client-Side)
    -- ========================================
    
    -- Bind F1 to show player info
keyMapping:reg('showinfo', 'Show Player Info', 'keyboard', 'F1')
commands:reg('showinfo', function()
  local health = players:hp()
  local coords = players:pos()
  local vehicle = vehicles:get()
  
  utils:print('=== Player Info ===')
  utils:print('Health: {1}', health)
  utils:print('Position: {1}, {2}, {3}', coords.x, coords.y, coords.z)
  utils:print('In Vehicle: {1}', vehicle ~= 0 and 'Yes' or 'No')
  
  if vehicle ~= 0 then
    local speed = GetEntitySpeed(vehicle) * 3.6
    utils:print('Vehicle Speed: {1} km/h', utils:round(speed, 1))
  end
end, false)
    
    -- ========================================
    -- ENVIRONMENT DETECTION (Client-Side)
    -- ========================================
    
    -- Verify we're on client
if not utils:client() then
  print('ERROR: This script should only run on client!')
  return
end
    
    print('Client environment detected correctly!')
    
    -- ========================================
    -- ERROR HANDLING EXAMPLES (Client-Side)
    -- ========================================
    
    -- Safe vehicle spawning
local function safeSpawnVehicle(model, coords)
  if not model or type(model) ~= 'string' then
    print('Invalid vehicle model provided')
    return 0
  end
  
  if not coords or not coords.x or not coords.y or not coords.z then
    print('Invalid coordinates provided')
    return 0
  end
  
  local vehicle = vehicles:spawn(model, coords)
  
  if vehicle == 0 then
    print('Failed to spawn vehicle:', model)
  else
    print('Successfully spawned vehicle:', model)
  end
  
  return vehicle
end

-- Safe teleportation
local function safeTeleport(coords)
  if not coords or not coords.x or not coords.y or not coords.z then
    print('Invalid coordinates for teleportation')
    return false
  end
  
  -- Check if coordinates are reasonable
  if math.abs(coords.x) > 10000 or math.abs(coords.y) > 10000 or math.abs(coords.z) > 1000 then
    print('Coordinates out of reasonable bounds')
    return false
  end
  
  players:tp(coords)
  print('Teleported to:', coords.x, coords.y, coords.z)
  return true
end
    
    print('Client example loaded successfully!')
    print('Available commands: /heal, /tp <x> <y> <z>, /car <model>, /status')
    print('Press F1 to show player info')
end 