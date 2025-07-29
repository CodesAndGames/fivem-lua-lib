fx_version "cerulean"
game "gta5"

author "Jax Danger/ CodesAndGames"
description "A FiveM Lua Library meant to make FiveM development easier."
version "0.0.1" -- last modified: 28/07/2025


shared_script "fivem-library.lua" -- Shared script for both client and server
server_script "server-example.lua" -- example server script utilizing the library
client_script "client-example.lua" -- example client script utilizing the library

escrow_ignore {
  "server-example.lua",
  "client-example.lua"
}
