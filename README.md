# FiveM Lua Library

A clean, object-oriented Lua library for FiveM development that simplifies common operations and provides a consistent API across client and server environments.

## 📚 Documentation

**Full documentation available at: [https://docs.jaxdanger.com/](https://docs.jaxdanger.com/)**

## 🚀 Installation

The jd-library is now its own script. Here's how to install it:

1. **Download** from GitHub
2. **Add** the folder to your `resources` directory of your FXServer
3. **Ensure** `jd-library` in your `server.cfg` before other resources that use it:
   ```
   ensure jd-library
   ensure your-script-name
   ```
4. **Add** `"@jd-library/init.lua"` to `shared_scripts` in the `fxmanifest.lua` file of any script that uses jd-library:
   ```lua
   shared_script '@jd-library/init.lua'
   ```

## 🚀 Quick Start

Once installed, you can use the library in your scripts:

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