-- Class System (Shared)
local Class = {}
Class.__index = Class

-- Create a new class
function Class.new(name, parent)
  local cls = {}
  cls.__name = name
  cls.__parent = parent
  cls.__methods = {}
  cls.__private = {}
  
  -- Set up inheritance
  if parent then
    setmetatable(cls, {__index = parent})
    cls.__super = parent
  end
  
  -- Constructor
  cls.__init = function(self, ...)
    if parent and parent.__init then
      parent.__init(self, ...)
    end
  end
  
  -- Method to add methods to class
  function cls:method(name, func)
    self.__methods[name] = func
  end
  
  -- Method to add private methods
  function cls:private(name, func)
    self.__private[name] = func
  end
  
  -- Constructor method (cleaner syntax)
  function cls:constructor(func)
    self.__init = func
  end
  
  -- Create instance
  function cls:new(...)
    local instance = {}
    instance.__class = cls
    instance.__name = cls.__name
    
    -- Copy methods
    for name, func in pairs(cls.__methods) do
      instance[name] = func
    end
    
    -- Set up inheritance chain
    if parent then
      setmetatable(instance, {__index = parent})
    end
    
    -- Call constructor
    if cls.__init then
      cls.__init(instance, ...)
    end
    
    return instance
  end
  
  -- Super method for calling parent methods
  function cls:super(methodName, ...)
    if parent then
      if methodName then
        -- Call specific parent method
        if parent[methodName] then
          return parent[methodName](self, ...)
        end
      else
        -- Call parent constructor
        if parent.__init then
          return parent.__init(self, ...)
        end
      end
    end
  end
  
  -- Check if instance is of type
  function cls:isInstanceOf(class)
    local current = self.__class
    while current do
      if current == class then
        return true
      end
      current = current.__parent
    end
    return false
  end
  
  -- Get class name
  function cls:getClassName()
    return self.__name
  end
  
  -- Extend class
  function cls:extend(name)
    return Class.new(name, cls)
  end
  
  return cls
end

-- Global class function for clean syntax
function class(name)
  return Class.new(name)
end

-- Make Class globally available
_G.Class = Class
_G.class = class

return Class 