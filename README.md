# FiveM Lua Library

A clean, object-oriented Lua library for FiveM development that simplifies common operations and provides a consistent API across client and server environments.

## 📚 Documentation

**Full documentation available at: [https://docs.jaxdanger.com/](https://docs.jaxdanger.com/)**

## 🚀 Quick Start

1. **Download** the `fivem-library.lua` file
2. **Add** it to your resource folder
3. **Include** it in your `fxmanifest.lua`:
   ```lua
   client_script 'fivem-library.lua'
   server_script 'fivem-library.lua'
   ```
4. **Use** the library in your scripts:
   ```lua
   -- Events
   events:on('playerSpawned', function()
     print('Player spawned!')
   end)
   
   -- Players
   players:setHp(200)
   players:tp({x = 100, y = 200, z = 30})
   
   -- Vehicles
   local vehicle = vehicles:spawn('adder', players:pos())
   
   -- Utils
   utils:print('Health: {1}', players:hp())
   ```

## ✨ Features

- **Object-Oriented API** - Clean method-based syntax
- **Environment Aware** - Works on both client and server
- **Global Access** - Use without `fivem.*` prefix
- **Short Commands** - Simplified command and key mapping registration
- **Template Strings** - Easy string formatting
- **Class System** - Built-in OOP support

## 📖 Learn More

Visit [https://docs.jaxdanger.com/](https://docs.jaxdanger.com/) for:
- Complete API reference
- Usage examples
- Best practices
- Migration guides
- Environment compatibility

---

**Created by @jax.danger** 
