fx_version "cerulean"
game "gta5"
lua54 "yes"
author "Jax Danger/ CodesAndGames"
description "A FiveM Lua Library meant to make FiveM development easier."
version "0.0.1" -- last modified: 28/07/2025

-- Load the Class system first as a shared script
shared_script "shared/class.lua"

-- Shared scripts (available to both client and server)
shared_scripts {
  "shared/events.lua",
  "shared/utils.lua",
  "shared/commands.lua",
  "imports/shared.lua"
}

-- Client scripts
client_scripts {
  "client/players.lua",
  "client/vehicles.lua",
  "client/keymapping.lua",
  "imports/client.lua",
  "init.lua"
}

-- Server scripts
server_scripts {
  "server/players.lua",
  "init.lua"
}

escrow_ignore {
	"init.lua"
}