-- Players class (Server-only)
local Players = class("Players")

Players:method("getId", function(self, id, id_type)
  if not (id or id_type) or id_type == "" then 
    id_type = "fivem"
  end
  local playerIdents = GetPlayerIdentifiers(id)
  for i = 1, #playerIdents do
    local ident = playerIdents[i]
    if ident:find(id_type) == 1 then
      return ident
    end
  end
  return nil
end)

Players:method("name", function(self, playerSource)
  local sourceToUse = playerSource or source
  return GetPlayerName(sourceToUse)
end)

-- Create instance
local players = Players:new()

-- Make Players instance globally available (server-side)
_ENV.players = players

return Players 