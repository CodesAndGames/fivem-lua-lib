# FiveM Lua Library - TODO List

## Helper Functions to Implement

### Player Shortcuts
- [ ] `players:isValid()` - check if player exists
- [ ] `players:distance()` - get distance between players  
- [ ] `players:getAll()` - get all players
- [ ] `players:getNearby()` - get players within radius
- [ ] `players:isInside()` - check if player is inside a building/interior
- [ ] `players:getHealth()` - get player health
- [ ] `players:getStamina()` - get player stamina
- [ ] `players:getOxygen()` - get player oxygen level
- [ ] `players:getSweat()` - get player sweat level
- [ ] `players:cuff()` - cuff a player
- [ ] `players:uncuff()` - uncuff a player
- [ ] `players:drag()` - drag a player
- [ ] `players:stopDrag()` - stop dragging a player
- [ ] `players:attach()` - attach player/NPC to another player
- [ ] `players:detach()` - detach player/NPC from player

### Vehicle Shortcuts
- [ ] `vehicles:isValid()` - check if vehicle exists
- [ ] `vehicles:getDriver()` - get vehicle driver
- [ ] `vehicles:getPassengers()` - get all passengers
- [ ] `vehicles:getFuel()` - get fuel level
- [ ] `vehicles:setFuel()` - set fuel level
- [ ] `vehicles:setColor()` - set vehicle color
- [ ] `vehicles:setLivery()` - set vehicle livery
- [ ] `vehicles:setArmor()` - set vehicle armor
- [ ] `vehicles:setSuspension()` - set suspension height

### Client Shortcuts
- [ ] `client:setWeather()` - change weather
- [ ] `client:setTime()` - set time of day
- [ ] `client:freezeTime()` - freeze/unfreeze time
- [ ] `client:setWeatherPersist()` - make weather persistent

### Animation Shortcuts
- [ ] `animations:play()` - play animation on player/NPC
- [ ] `animations:stop()` - stop animation
- [ ] `animations:isPlaying()` - check if animation is playing

### NPC Shortcuts
- [ ] `npcs:spawn()` - spawn NPC
- [ ] `npcs:delete()` - delete NPC
- [ ] `npcs:setAngry()` - make NPC angry
- [ ] `npcs:setPath()` - set NPC movement path
- [ ] `npcs:follow()` - make NPC follow target
- [ ] `npcs:getNearby()` - get nearby NPCs

### Command Shortcuts
- [ ] `commands:add()` - shorter RegisterCommand

### Entity Shortcuts
- [ ] `entities:isValid()` - check any entity
- [ ] `entities:delete()` - delete any entity
- [ ] `entities:getType()` - get entity type

### Coordinate Shortcuts
- [ ] `coords:distance()` - distance between coords
- [ ] `coords:random()` - random ground coordinates within rectangle area (excludes interiors)

## Notes
- All functions should be simple shortcuts that wrap common FiveM natives
- Focus on making development faster and cleaner
- Maintain consistency with existing API patterns
- Test all functions thoroughly before release
