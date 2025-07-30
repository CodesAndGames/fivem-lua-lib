--[[
  Enhanced Class System (Shared)
  Based on ox_lib with improvements for jd-library
]]

local getinfo = debug.getinfo

-- Fallback implementations for table functions
if not table.clone then
    function table.clone(t)
        local copy = {}
        for k, v in pairs(t) do
            copy[k] = v
        end
        return copy
    end
end

if not table.wipe then
    function table.wipe(t)
        for k in pairs(t) do
            t[k] = nil
        end
    end
end

---Ensure the given argument or property has a valid type, otherwise throwing an error.
---@param id number | string
---@param var any
---@param expected type
local function assertType(id, var, expected)
    local received = type(var)

    if received ~= expected then
        error(("expected %s %s to have type '%s' (received %s)")
            :format(type(id) == 'string' and 'field' or 'argument', id, expected, received), 3)
    end

    return true
end

---@alias ClassConstructor<T> fun(self: T, ...: unknown): nil

---@class Class
---@field private __index table
---@field protected __name string
---@field protected __parent? Class
---@field protected private? { [string]: unknown }
---@field protected super? ClassConstructor
---@field protected constructor? ClassConstructor
local mixins = {}
local constructors = {}

---Somewhat hacky way to remove the constructor from the class.__index.
---@param class Class
local function getConstructor(class)
  local constructor = constructors[class] or class.constructor

  if class.constructor then
    constructors[class] = class.constructor
    class.constructor = nil
  end

  return constructor
end

local function void() return '' end

---Creates a new instance of the given class.
---@protected
---@generic T
---@param class T | Class
---@return T
function mixins:new(...)
  local constructor = getConstructor(self)
  local private = {}
  local obj = setmetatable({ private = private }, self)

  if constructor then
    local parent = self

    rawset(obj, 'super', function(self, ...)
      parent = getmetatable(parent)
      constructor = getConstructor(parent)

      if constructor then return constructor(self, ...) end
    end)

    constructor(obj, ...)
  end

  rawset(obj, 'super', nil)

  if private ~= obj.private or next(obj.private) then
    private = table.clone(obj.private)

    table.wipe(obj.private)
    setmetatable(obj.private, {
      __metatable = 'private',
      __tostring = void,
      __index = function(self, index)
        local di = getinfo(2, 'n')

        if di.namewhat ~= 'method' and di.namewhat ~= '' then return end

        return private[index]
      end,
      __newindex = function(self, index, value)
        local di = getinfo(2, 'n')

        if di.namewhat ~= 'method' and di.namewhat ~= '' then
          error(("cannot set value of private field '%s'"):format(index), 2)
        end

        private[index] = value
      end
    })
  else
    obj.private = nil
  end

  return obj
end

---Checks if an object is an instance of the given class.
---@param class Class
function mixins:isClass(class)
  return getmetatable(self) == class
end

---Checks if an object is an instance or derivative of the given class.
---@param class Class
function mixins:instanceOf(class)
  local mt = getmetatable(self)

  while mt do
    if mt == class then return true end

    mt = getmetatable(mt)
  end

  return false
end

---Get the class name of an instance
function mixins:getClassName()
  return self.__name
end

---Extend this class with a new subclass
---@param name string
---@return Class
function mixins:extend(name)
  assertType(1, name, 'string')
  return class(name, self)
end

---Constructor method for cleaner syntax
---@param func ClassConstructor
function mixins:constructor(func)
    self.constructor = func
end

---Method to add methods to class
---@param name string
---@param func function
function mixins:method(name, func)
    self._allowMethodAssignment = true
    self[name] = func
    self._allowMethodAssignment = false
end

---Method to add private methods
---@param name string
---@param func function
function mixins:private(name, func)
    self._allowMethodAssignment = true
    self[name] = func
    self._allowMethodAssignment = false
end

---Creates a new class.
---@generic S : Class
---@generic T : string
---@param name `T`
---@param super? S
---@return `T`
function class(name, super)
    assertType(1, name, 'string')

    local class = table.clone(mixins)

    class.__name = name
    class.__index = class

    if super then
        assertType('super', super, 'table')
        setmetatable(class, super)
        class.__parent = super
    end

    -- Prevent direct assignment to class methods
    setmetatable(class, {
        __index = getmetatable(class),
        __newindex = function(self, key, value)
            if type(value) == 'function' and not self._allowMethodAssignment then
                error(("use :method('%s', function) instead of direct assignment"):format(key), 2)
            end
            rawset(self, key, value)
        end
    })

    return class
end

-- Make class globally available
_G.class = class

return class 