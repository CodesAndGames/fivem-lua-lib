-- Players class (Client-only)
local Players = class("Players")

Players:method("get", function(self, playerId)
  return GetPlayerPed(playerId or PlayerId())
end)

Players:method("serverId", function(self)
  return GetPlayerServerId(PlayerId())
end)

Players:method("localId", function(self)
  return PlayerId()
end)

Players:method("pos", function(self)
  local ped = GetPlayerPed(PlayerId())
  return GetEntityCoords(ped)
end)

Players:method("hp", function(self)
  local ped = GetPlayerPed(PlayerId())
  return GetEntityHealth(ped)
end)

Players:method("setHp", function(self, health)
  local ped = GetPlayerPed(PlayerId())
  SetEntityHealth(ped, health)
end)

Players:method("name", function(self)
  return GetPlayerName(PlayerId())
end)

-- Make Players globally available
_G.Players = Players

return Players 