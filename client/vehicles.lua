-- Vehicles class (Client-only)
local Vehicles = class("Vehicles")

Vehicles:method("get", function(self)
  return GetVehiclePedIsIn(PlayerPedId(), false)
end)

Vehicles:method("spawn", function(self, model, coords)
  local hash = GetHashKey(model)
  RequestModel(hash)
  while not HasModelLoaded(hash) do
    Wait(0)
  end
  local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, 0.0, true, false)
  SetModelAsNoLongerNeeded(hash)
  return vehicle
end)

Vehicles:method("putIn", function(self, vehicle)
  local ped = PlayerPedId()
  TaskWarpPedIntoVehicle(ped, vehicle, -1)
end)

Vehicles:method("del", function(self, vehicle)
  if DoesEntityExist(vehicle) then
    DeleteEntity(vehicle)
  end
end)

Vehicles:method("pos", function(self, vehicle)
  return GetEntityCoords(vehicle)
end)

-- Create instance
local vehicles = Vehicles:new()

-- Make Vehicles instance globally available (client-side)
_ENV.vehicles = vehicles

return Vehicles 