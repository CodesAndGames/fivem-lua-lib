-- Server-Side Example using FiveM Library
-- This file demonstrates server-side functionality only

-- Wait for the library to load
Citizen.CreateThread(function()
  while not fivem do
    Citizen.Wait(100)
  end

  utils:print('FiveM Library loaded on server!')
  startServerExample()
end)

function startServerExample()
  -- ========================================
  -- EVENTS EXAMPLES (Server-Side)
  -- ========================================

  -- Handle player connections
  events:on('playerConnecting', function(name, setKickReason, deferrals)
    local playerId = source
    utils:print('Player connecting: {1} ID: {2}', name, playerId or 'Unknown')

    -- Store player data
    playerDatabase[playerId] = {
      name = name,
      connectedAt = os.time(),
      health = 200,
      money = 1000,
      level = 1
    }

    -- Send welcome message
    events:emitClient('serverMessage', playerId, utils:tmpl('Welcome to the server, ${name}!', name))
  end)

  -- Handle player disconnections
  events:on('playerDropped', function(reason)
    local playerId = source
    local playerData = playerDatabase[playerId]

    if playerData then
      utils:print('Player disconnected: {1} ID: {2} Reason: {3}', playerData.name, playerId, reason)

      -- Save player data before removing
      savePlayerData(playerId, playerData)
      playerDatabase[playerId] = nil
    end
  end)

  -- Handle player ready event from client
  events:on('playerReady', function()
    local playerId = source
    local playerData = playerDatabase[playerId]

    if playerData then
      utils:print('Player ready: {1} ID: {2}', playerData.name, playerId)

      -- Set player health
      players:setHp(playerId, playerData.health)

      -- Send player info
      events:emitClient('playerInfo', playerId, playerData)
    end
  end)

  -- Handle low health warnings from client
  events:on('lowHealthWarning', function(health)
    local playerId = source
    local playerData = playerDatabase[playerId]

    if playerData then
      utils:print('Low health warning for {1} Health: {2}', playerData.name, health)

      -- Auto-heal if health is critically low
      if health < 25 then
        players:setHp(playerId, 100)
        events:emitClient('serverMessage', playerId, 'You have been auto-healed!')
      end
    end
  end)

  -- Handle vehicle spawn confirmations
  events:on('vehicleSpawned', function(model)
    local playerId = source
    local playerData = playerDatabase[playerId]

    if playerData then
      utils:print('Vehicle spawned by {1} Model: {2}', playerData.name, model)

      -- Log vehicle spawn
      logVehicleSpawn(playerId, model)
    end
  end)

  -- Handle client messages
  events:on('clientMessage', function(message)
    local playerId = source
    local playerData = playerDatabase[playerId]

    if playerData then
      utils:print('Message from {1}: {2}', playerData.name, message)
    end
  end)

  -- ========================================
  -- PLAYER MANAGEMENT EXAMPLES (Server-Side)
  -- ========================================

  -- Player database
  local playerDatabase = {}

  -- Get all online players
  local function getOnlinePlayers()
    local onlinePlayers = {}
    for playerId, data in pairs(playerDatabase) do
      if data then
        local playerPos = players:pos(playerId)
        local playerHealth = players:hp(playerId)

        table.insert(onlinePlayers, {
          id = playerId,
          name = data.name,
          health = playerHealth,
          coords = playerPos
        })
      end
    end
    return onlinePlayers
  end

  -- Find player by name
  local function findPlayerByName(name)
    for playerId, data in pairs(playerDatabase) do
      if data and data.name:lower() == name:lower() then
        return playerId, data
      end
    end
    return nil, nil
  end

  -- Get players in area
  local function getPlayersInArea(centerCoords, radius)
    local playersInArea = {}

    for playerId, data in pairs(playerDatabase) do
      if data then
        local playerCoords = players:pos(playerId)
        local distance = utils:dist(centerCoords, playerCoords)

        if distance <= radius then
          table.insert(playersInArea, {
            id = playerId,
            name = data.name,
            distance = utils:round(distance, 2)
          })
        end
      end
    end

    return playersInArea
  end

  -- ========================================
  -- UTILITIES EXAMPLES (Server-Side)
  -- ========================================

  -- Logging system
  local function logServerEvent(event, playerId, data)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local playerName = playerDatabase[playerId] and playerDatabase[playerId].name or 'Unknown'

    local logMessage = utils:tmpl('[${timestamp}] ${event} - Player: ${playerName} (${playerId}) - Data: ${data}',
      timestamp, event, playerName, playerId, data or 'N/A')

    utils:print(logMessage)
    return logMessage
  end

  -- Vehicle spawn logging
  local function logVehicleSpawn(playerId, model)
    logServerEvent('VEHICLE_SPAWN', playerId, model)
  end

  -- Player data saving
  local function savePlayerData(playerId, data)
    -- In a real implementation, you would save to database
    local saveMessage = utils:tmpl('Saving data for ${name} (${id}): Health=${health}, Money=${money}, Level=${level}',
      data.name, playerId, data.health, data.money, data.level)

    utils:print(saveMessage)
    return saveMessage
  end

  -- ========================================
  -- CLASS SYSTEM EXAMPLES (Server-Side)
  -- ========================================

  -- Create a ServerPlayer class
  local ServerPlayer = Class.create("ServerPlayer")

  ServerPlayer:constructor(function(self, playerId, name)
    self.playerId = playerId
    self.name = name
    self.connectedAt = os.time()
    self.lastActivity = os.time()
    self.vehicleSpawns = 0
    self.totalPlayTime = 0
  end)

  ServerPlayer:method("updateActivity", function(self)
    self.lastActivity = os.time()
  end)

  ServerPlayer:method("addVehicleSpawn", function(self)
    self.vehicleSpawns = self.vehicleSpawns + 1
  end)

  ServerPlayer:method("getPlayTime", function(self)
    return os.time() - self.connectedAt
  end)

  ServerPlayer:method("getFormattedPlayTime", function(self)
    local playTime = self:getPlayTime()
    local hours = math.floor(playTime / 3600)
    local minutes = math.floor((playTime % 3600) / 60)

    return utils:tmpl('${hours}h ${minutes}m', hours, minutes)
  end)

  ServerPlayer:method("sendMessage", function(self, message)
    events:emitClient('serverMessage', self.playerId, message)
  end)

  ServerPlayer:method("heal", function(self)
    players:setHp(self.playerId, 200)
    self:sendMessage('You have been healed!')
  end)

  ServerPlayer:method("teleport", function(self, coords)
    players:tp(self.playerId, coords)
    self:sendMessage('You have been teleported!')
  end)

  ServerPlayer:method("getPosition", function(self)
    return players:pos(self.playerId)
  end)

  ServerPlayer:method("getHealth", function(self)
    return players:hp(self.playerId)
  end)

  ServerPlayer:method("requestVehicleSpawn", function(self, model)
    events:emitClient('spawnVehicle', self.playerId, model)
    self:addVehicleSpawn()
    utils:print('Vehicle spawn requested for {1}: {2}', self.name, model)
  end)

  -- Create server player instances
  local serverPlayers = {}

  -- Update player activity every minute
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(60000) -- Every minute

      for playerId, player in pairs(serverPlayers) do
        player:updateActivity()
      end
    end
  end)

  -- ========================================
  -- COMMAND EXAMPLES (Server-Side)
  -- ========================================

  -- Admin commands
  commands:reg('healall', function(source, args)
    if source == 0 then -- Console command
      for playerId, data in pairs(playerDatabase) do
        players:setHp(playerId, 200)
        events:emitClient('serverMessage', playerId, 'All players have been healed!')
      end
      utils:print('All players healed by console')
    else
      utils:print('This command can only be used from console')
    end
  end, true)

  commands:reg('healplayer', function(source, args)
    if source == 0 and #args >= 1 then -- Console command
      local targetName = args[1]
      local targetId, targetData = findPlayerByName(targetName)

      if targetId then
        players:setHp(targetId, 200)
        events:emitClient('serverMessage', targetId, 'You have been healed by admin!')
        utils:print('Player {1} healed by console', targetName)
      else
        utils:print('Player not found: {1}', targetName)
      end
    else
      utils:print('Usage: healplayer <playername> (console only)')
    end
  end, true)

  commands:reg('tpplayer', function(source, args)
    if source == 0 and #args >= 4 then -- Console command
      local targetName = args[1]
      local x = tonumber(args[2])
      local y = tonumber(args[3])
      local z = tonumber(args[4])

      if x and y and z then
        local targetId, targetData = findPlayerByName(targetName)

        if targetId then
          players:tp(targetId, {x = x, y = y, z = z})
          events:emitClient('serverMessage', targetId, 'You have been teleported by admin!')
          utils:print('Player {1} teleported to {2}, {3}, {4}', targetName, x, y, z)
        else
          utils:print('Player not found: {1}', targetName)
        end
      else
        utils:print('Invalid coordinates')
      end
    else
      utils:print('Usage: tpplayer <playername> <x> <y> <z> (console only)')
    end
  end, true)

  commands:reg('players', function(source, args)
    if source == 0 then -- Console command
      local onlinePlayers = getOnlinePlayers()
      utils:print('=== Online Players ===')
      utils:print('Total players: {1}', #onlinePlayers)

      for _, player in ipairs(onlinePlayers) do
        utils:print('ID: {1} | Name: {2} | Health: {3}',
          player.id, player.name, player.health)
      end
    else
      utils:print('This command can only be used from console')
    end
  end, true)

  commands:reg('spawnvehicle', function(source, args)
    if source == 0 and #args >= 2 then -- Console command
      local targetName = args[1]
      local model = args[2]

      local targetId, targetData = findPlayerByName(targetName)

      if targetId then
        events:emitClient('spawnVehicle', targetId, model)
        utils:print('Vehicle spawn requested for {1} Model: {2}', targetName, model)
      else
        utils:print('Player not found: {1}', targetName)
      end
    else
      utils:print('Usage: spawnvehicle <playername> <model> (console only)')
    end
  end, true)

  commands:reg('playerinfo', function(source, args)
    if source == 0 and #args >= 1 then -- Console command
      local targetName = args[1]
      local targetId, targetData = findPlayerByName(targetName)

      if targetId then
        local playerPos = players:pos(targetId)
        local playerHealth = players:hp(targetId)

        utils:print('=== Player Info ===')
        utils:print('Name: {1}', targetData.name)
        utils:print('ID: {1}', targetId)
        utils:print('Health: {1}', playerHealth)
        utils:print('Position: {1}, {2}, {3}', playerPos.x, playerPos.y, playerPos.z)
        utils:print('Money: {1}', targetData.money)
        utils:print('Level: {1}', targetData.level)
      else
        utils:print('Player not found: {1}', targetName)
      end
    else
      utils:print('Usage: playerinfo <playername> (console only)')
    end
  end, true)

  -- ========================================
  -- ENVIRONMENT DETECTION (Server-Side)
  -- ========================================

  -- Verify we're on server
  if not utils:server() then
    utils:print('ERROR: This script should only run on server!')
    return
  end

  utils:print('Server environment detected correctly!')

  -- ========================================
  -- ERROR HANDLING EXAMPLES (Server-Side)
  -- ========================================

  -- Safe player operations
  local function safePlayerOperation(playerId, operation, ...)
    if not playerId or type(playerId) ~= 'number' then
      utils:print('Invalid player ID provided')
      return false
    end

    if not playerDatabase[playerId] then
      utils:print('Player not found in database: {1}', playerId)
      return false
    end

    local success, result = pcall(operation, playerId, ...)

    if not success then
      utils:print('Player operation failed: {1}', result)
      return false
    end

    return result
  end

  -- Safe teleportation
  local function safeTeleportPlayer(playerId, coords)
    return safePlayerOperation(playerId, function(id, targetCoords)
      if not targetCoords or not targetCoords.x or not targetCoords.y or not targetCoords.z then
        error('Invalid coordinates provided')
      end

      -- Check if coordinates are reasonable
      if math.abs(targetCoords.x) > 10000 or math.abs(targetCoords.y) > 10000 or math.abs(targetCoords.z) > 1000 then
        error('Coordinates out of reasonable bounds')
      end

      players:tp(id, targetCoords)
      events:emitClient('serverMessage', id, 'You have been teleported!')
      return true
    end, coords)
  end

  -- Safe healing
  local function safeHealPlayer(playerId, health)
    return safePlayerOperation(playerId, function(id, targetHealth)
      if not targetHealth or type(targetHealth) ~= 'number' or targetHealth < 0 or targetHealth > 200 then
        error('Invalid health value')
      end

      players:setHp(id, targetHealth)
      events:emitClient('serverMessage', id, 'Your health has been updated!')
      return true
    end, health or 200)
  end

  -- ========================================
  -- PERIODIC TASKS (Server-Side)
  -- ========================================

  -- Server status update every 5 minutes
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(300000) -- 5 minutes

      local onlinePlayers = getOnlinePlayers()
      local serverUptime = GetGameTimer() / 1000 / 60 -- minutes

      utils:print('=== Server Status ===')
      utils:print('Online players: {1}', #onlinePlayers)
      utils:print('Server uptime: {1} minutes', utils:round(serverUptime, 1))
      utils:print('Memory usage: {1} KB', collectgarbage('count'))
    end
  end)

  -- Clean up inactive players every 10 minutes
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(600000) -- 10 minutes

      local currentTime = os.time()
      for playerId, player in pairs(serverPlayers) do
        if currentTime - player.lastActivity > 3600 then -- 1 hour inactive
          utils:print('Removing inactive player: {1}', player.name)
          serverPlayers[playerId] = nil
        end
      end
    end
  end)

  -- Player activity monitoring every 30 seconds
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(30000) -- 30 seconds

      for playerId, data in pairs(playerDatabase) do
        if data then
          local playerHealth = players:hp(playerId)
          local playerPos = players:pos(playerId)

          -- Update player data
          data.health = playerHealth

          -- Log if player is in unusual location
          if playerPos and (math.abs(playerPos.x) > 10000 or math.abs(playerPos.y) > 10000) then
            utils:print('Player {1} in unusual location: {2}, {3}, {4}',
              data.name, playerPos.x, playerPos.y, playerPos.z)
          end
        end
      end
    end
  end)

  utils:print('Server example loaded successfully!')
  utils:print('Available console commands: /healall, /healplayer <name>, /tpplayer <name> <x> <y> <z>, /players, /spawnvehicle <name> <model>, /playerinfo <name>')
end