-- Client-Side Example using FiveM Library
-- This file demonstrates client-side functionality only

-- Wait for the library to load
Citizen.CreateThread(function()
  while not fivem do
    Citizen.Wait(100)
  end

  utils:print('FiveM Library loaded on client!')
  startClientExample()
end)

function startClientExample()
  -- ========================================
  -- EVENTS EXAMPLES (Client-Side)
  -- ========================================

  -- Handle server messages
  events:on('serverMessage', function(message)
    utils:print('Server says: {1}', message)
  end)

  -- Handle player info from server
  events:on('playerInfo', function(playerData)
    utils:print('Player info received: {1}', playerData.name)
    utils:print('Health: {1}, Money: {2}, Level: {3}', playerData.health, playerData.money, playerData.level)
  end)

  -- Handle vehicle spawn requests from server
  events:on('spawnVehicle', function(model)
    local playerPos = players:pos()
    local vehicle = vehicles:spawn(model, playerPos)

    if vehicle and vehicle ~= 0 then
      utils:print('Vehicle spawned: {1}', model)
      events:emitServer('vehicleSpawned', model)
    else
      utils:print('Failed to spawn vehicle: {1}', model)
    end
  end)

  -- ========================================
  -- PLAYER MANAGEMENT EXAMPLES (Client-Side)
  -- ========================================

  -- Get local player info
  local function getLocalPlayerInfo()
    local playerId = players:localId()
    local serverId = players:serverId()
    local playerName = players:name()
    local playerPos = players:pos()
    local playerHealth = players:hp()

    return {
      localId = playerId,
      serverId = serverId,
      name = playerName,
      position = playerPos,
      health = playerHealth
    }
  end

  -- Monitor player health
  local function monitorHealth()
    local currentHealth = players:hp()

    if currentHealth < 50 then
      utils:print('Low health warning: {1}', currentHealth)
      events:emitServer('lowHealthWarning', currentHealth)
    end
  end

  -- ========================================
  -- VEHICLE MANAGEMENT EXAMPLES (Client-Side)
  -- ========================================

  -- Get current vehicle info
  local function getCurrentVehicleInfo()
    local vehicle = vehicles:get()

    if vehicle and vehicle ~= 0 then
      local vehiclePos = vehicles:pos(vehicle)
      return {
        handle = vehicle,
        position = vehiclePos
      }
    end

    return nil
  end

  -- Spawn vehicle at player location
  local function spawnVehicleAtPlayer(model)
    local playerPos = players:pos()
    local vehicle = vehicles:spawn(model, playerPos)

    if vehicle and vehicle ~= 0 then
      utils:print('Vehicle {1} spawned at player location', model)
      return vehicle
    else
      utils:print('Failed to spawn vehicle {1}', model)
      return nil
    end
  end

  -- Delete current vehicle
  local function deleteCurrentVehicle()
    local vehicle = vehicles:get()

    if vehicle and vehicle ~= 0 then
      vehicles:del(vehicle)
      utils:print('Current vehicle deleted')
      return true
    else
      utils:print('No vehicle to delete')
      return false
    end
  end

  -- ========================================
  -- UTILITIES EXAMPLES (Client-Side)
  -- ========================================

  -- Calculate distance between two points
  local function calculateDistance(pos1, pos2)
    return utils:dist(pos1, pos2)
  end

  -- Round numbers
  local function roundNumber(num, decimals)
    return utils:round(num, decimals)
  end

  -- Template string example
  local function createWelcomeMessage(playerName, serverName)
    return utils:tmpl('Welcome ${playerName} to ${serverName}!', playerName, serverName)
  end

  -- ========================================
  -- CLASS SYSTEM EXAMPLES (Client-Side)
  -- ========================================

  -- Create a ClientPlayer class
  local ClientPlayer = Class.create("ClientPlayer")

  ClientPlayer:constructor(function(self)
    self.localId = players:localId()
    self.serverId = players:serverId()
    self.name = players:name()
    self.lastHealthCheck = 0
    self.vehicleHistory = {}
  end)

  ClientPlayer:method("updateInfo", function(self)
    self.name = players:name()
    self.serverId = players:serverId()
  end)

  ClientPlayer:method("getPosition", function(self)
    return players:pos()
  end)

  ClientPlayer:method("getHealth", function(self)
    return players:hp()
  end)

  ClientPlayer:method("setHealth", function(self, health)
    players:setHp(self.localId, health)
  end)

  ClientPlayer:method("teleport", function(self, coords)
    players:tp(self.localId, coords)
  end)

  ClientPlayer:method("heal", function(self)
    self:setHealth(200)
    utils:print('Player {1} has been healed', self.name)
  end)

  ClientPlayer:method("getCurrentVehicle", function(self)
    return vehicles:get()
  end)

  ClientPlayer:method("spawnVehicle", function(self, model)
    local playerPos = self:getPosition()
    local vehicle = vehicles:spawn(model, playerPos)

    if vehicle and vehicle ~= 0 then
      table.insert(self.vehicleHistory, {
        model = model,
        timestamp = GetGameTimer()
      })
      utils:print('Vehicle {1} spawned for {2}', model, self.name)
    end

    return vehicle
  end)

  ClientPlayer:method("deleteCurrentVehicle", function(self)
    local vehicle = self:getCurrentVehicle()

    if vehicle and vehicle ~= 0 then
      vehicles:del(vehicle)
      utils:print('Vehicle deleted for {1}', self.name)
      return true
    end

    return false
  end)

  ClientPlayer:method("sendMessage", function(self, message)
    events:emitServer('clientMessage', message)
  end)

  -- Create client player instance
  local clientPlayer = ClientPlayer:new()

  -- ========================================
  -- COMMAND EXAMPLES (Client-Side)
  -- ========================================

  -- Register client commands
  commands:reg('heal', function()
    clientPlayer:heal()
  end)

  commands:reg('pos', function()
    local pos = clientPlayer:getPosition()
    utils:print('Position: {1}, {2}, {3}', pos.x, pos.y, pos.z)
  end)

  commands:reg('spawncar', function(source, args)
    if #args >= 1 then
      local model = args[1]
      clientPlayer:spawnVehicle(model)
    else
      utils:print('Usage: /spawncar <model>')
    end
  end)

  commands:reg('delcar', function()
    clientPlayer:deleteCurrentVehicle()
  end)

  commands:reg('tp', function(source, args)
    if #args >= 3 then
      local x = tonumber(args[1])
      local y = tonumber(args[2])
      local z = tonumber(args[3])

      if x and y and z then
        clientPlayer:teleport({x = x, y = y, z = z})
        utils:print('Teleported to {1}, {2}, {3}', x, y, z)
      else
        utils:print('Invalid coordinates')
      end
    else
      utils:print('Usage: /tp <x> <y> <z>')
    end
  end)

  commands:reg('info', function()
    local info = getLocalPlayerInfo()
    utils:print('=== Player Info ===')
    utils:print('Name: {1}', info.name)
    utils:print('Local ID: {1}', info.localId)
    utils:print('Server ID: {1}', info.serverId)
    utils:print('Health: {1}', info.health)
    utils:print('Position: {1}, {2}, {3}', info.position.x, info.position.y, info.position.z)
  end)

  -- Add command suggestions
  commands:suggest('heal', 'Heal yourself to full health')
  commands:suggest('pos', 'Show your current position')
  commands:suggest('spawncar', 'Spawn a vehicle', {{name = 'model', help = 'Vehicle model name'}})
  commands:suggest('delcar', 'Delete your current vehicle')
  commands:suggest('tp', 'Teleport to coordinates', {
    {name = 'x', help = 'X coordinate'},
    {name = 'y', help = 'Y coordinate'},
    {name = 'z', help = 'Z coordinate'}
  })
  commands:suggest('info', 'Show player information')

  -- ========================================
  -- KEY MAPPING EXAMPLES (Client-Side)
  -- ========================================

  -- Register key mappings
  keyMapping:reg('client_heal', 'Heal player', 'keyboard', 'H')
  keyMapping:reg('client_info', 'Show player info', 'keyboard', 'I')
  keyMapping:reg('client_spawn_car', 'Spawn random car', 'keyboard', 'C')

  -- Handle key mapping commands
  commands:reg('client_heal', function()
    clientPlayer:heal()
  end)

  commands:reg('client_info', function()
    commands:reg('info', function() end) -- Call the info command
  end)

  commands:reg('client_spawn_car', function()
    local carModels = {'adder', 'zentorno', 't20', 'osiris', 'xa21'}
    local randomModel = carModels[math.random(#carModels)]
    clientPlayer:spawnVehicle(randomModel)
  end)

  -- ========================================
  -- ENVIRONMENT DETECTION (Client-Side)
  -- ========================================

  -- Verify we're on client
  if not utils:client() then
    utils:print('ERROR: This script should only run on client!')
    return
  end

  utils:print('Client environment detected correctly!')

  -- ========================================
  -- ERROR HANDLING EXAMPLES (Client-Side)
  -- ========================================

  -- Safe player operations
  local function safePlayerOperation(operation, ...)
    local success, result = pcall(operation, ...)

    if not success then
      utils:print('Player operation failed: {1}', result)
      return false
    end

    return result
  end

  -- Safe teleportation
  local function safeTeleport(coords)
    return safePlayerOperation(function(targetCoords)
      if not targetCoords or not targetCoords.x or not targetCoords.y or not targetCoords.z then
        error('Invalid coordinates provided')
      end

      -- Check if coordinates are reasonable
      if math.abs(targetCoords.x) > 10000 or math.abs(targetCoords.y) > 10000 or math.abs(targetCoords.z) > 1000 then
        error('Coordinates out of reasonable bounds')
      end

      clientPlayer:teleport(targetCoords)
      return true
    end, coords)
  end

  -- Safe vehicle spawning
  local function safeSpawnVehicle(model)
    return safePlayerOperation(function(vehicleModel)
      if not vehicleModel or type(vehicleModel) ~= 'string' then
        error('Invalid vehicle model')
      end

      if #vehicleModel < 1 or #vehicleModel > 50 then
        error('Vehicle model name too short or too long')
      end

      return clientPlayer:spawnVehicle(vehicleModel)
    end, model)
  end

  -- ========================================
  -- PERIODIC TASKS (Client-Side)
  -- ========================================

  -- Health monitoring thread
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(5000) -- Every 5 seconds

      monitorHealth()
      clientPlayer:updateInfo()
    end
  end)

  -- Position logging thread
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(30000) -- Every 30 seconds

      local pos = clientPlayer:getPosition()
      local health = clientPlayer:getHealth()

      utils:print('Status - Health: {1}, Position: {2}, {3}, {4}',
        health, pos.x, pos.y, pos.z)
    end
  end)

  -- Vehicle monitoring thread
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(10000) -- Every 10 seconds

      local vehicle = clientPlayer:getCurrentVehicle()

      if vehicle and vehicle ~= 0 then
        local vehiclePos = vehicles:pos(vehicle)
        utils:print('In vehicle at: {1}, {2}, {3}',
          vehiclePos.x, vehiclePos.y, vehiclePos.z)
      end
    end
  end)

  -- ========================================
  -- INITIALIZATION
  -- ========================================

  -- Notify server that client is ready
  Citizen.CreateThread(function()
    Citizen.Wait(2000) -- Wait 2 seconds for everything to load
    events:emitServer('playerReady')
    utils:print('Client ready! Notified server.')
  end)

  utils:print('Client example loaded successfully!')
  utils:print('Available commands: /heal, /pos, /spawncar <model>, /delcar, /tp <x> <y> <z>, /info')
  utils:print('Key mappings: H (heal), I (info), C (spawn random car)')
end 