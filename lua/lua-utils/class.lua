local copy = require 'lua-utils.copy'
require 'lua-utils.utils'

--- Create classes and instances
local class = {}

setmetatable(class, class)

function class.is_object(obj)
  if type(obj) ~= 'table' then
    return false, ('expected table, got ' .. dump(obj))
  elseif not obj.__object then
    return false, ('expected object, got ' .. dump(obj))
  else
    return true
  end
end

function class.is_instance(obj)
  if type(obj) ~= 'table' then
    return false, ('expected table, got ' .. dump(obj))
  elseif not obj.__object then
    return false, ('expected object, got ' .. dump(obj))
  elseif not obj.__instance then
    return false, ('expected instance, got class: ' .. dump(obj))
  else
    return true
  end
end

function class.is_class(obj)
  if type(obj) ~= 'table' then
    return false, ('expected table, got ' .. dump(obj))
  elseif not obj.__object then
    return false, ('expected object, got ' .. dump(obj))
  elseif obj.__instance then
    return false, ('expected class, got instance: ' .. dump(obj))
  else
    return true
  end
end

function class.inherits(obj, cls)
  assert(class.is_object(obj))
  assert(class.is_object(cls))

  cls = ifelse(cls.__instance, cls.__class, cls)
  obj = ifelse(obj.__instance, obj.__class, obj)

  if obj == cls then
    return true
  end

  local parent = obj.__inherits
  while true do
    if not parent then
      return false
    elseif parent == cls then
      return true
    else
      parent = parent.__inherits
    end
  end
end

function class.is_parent_of(cls, obj)
  return class.inherits(cls, obj)
end

function class.is_child_of(obj, cls)
  return class.inherits(obj, cls)
end

function class.copy(x)
  return copy.copy(x)
end

function class.deep_copy(x)
  return copy.deep(x)
end

--- Is x a parent of y?
function class.parent_of(x, y)
  return class.child_of(y, x)
end

function class.super(obj, ...)
  local function find_init(x)
    if x.__instance then
      x = x.__class
    end

    if x.initialize then
      return x.initialize
    elseif not x.__inherits then
      return
    end

    x = x.__inherits
    if x.initialize then
      return x.initialize
    else
      return find_init(x)
    end
  end

  local init = find_init(obj)
  if init then init(obj, ...) end
end

function class.methods(x)
  local res = {}
  for key, _ in pairs(x.__methods) do
    res[key] = x[key]
  end

  return res
end

function class.attributes(x)
  local res = {}
  for key, _ in pairs(x.__attributes) do
    res[key] = x[key]
  end

  return res
end

function class.attribute(x, attrib)
  local value = x.__attributes[attrib]
  return ifelse(value, x[attrib])
end

function class.method(x, attrib)
  local value = x.__methods[attrib]
  return ifelse(value, x[attrib])
end

function class.metamethods(x)
  local res = {}
  for key, _ in pairs(x.__metamethods) do
    res[key] = x[key]
  end
  return res
end

function class.metaattributes(x)
  local res = {}
  for key, _ in pairs(x.__metaattributes) do
    res[key] = x[key]
  end
  return res
end

function class.include(self, from)
  for key, value in pairs(from) do
    if self[key] == nil then self[key] = value end
  end

  return self end

function class.new(name, inherits)
  return class(name, inherits)
end

function class.get_class(x)
  if not class.is_object(x) then
    return nil
  elseif x.__instance then
    return x.__class
  else
    return x
  end
end

function class.set(self, key, value)
  if class.is_object(value) or not callable(value) then
    if tostring(key):match '^__' then
      self.__metaattributes[key] = true
    else
      self.__attributes[key] = true
    end
  else
    if tostring(key):match '^__' then
      self.__metamethods[key] = true
    else
      self.__methods[key] = true
    end
  end

  rawset(self, key, value)
end

function class.create_instance_method(self, method)
  if not self[method] then
    return false
  else
    return function (...)
      return self[method](self, ...)
    end
  end
end

function class.create_instance(cls, defaults, ...)
  local obj = {
    __metaattributes = cls.__metaattributes, __metamethods = cls.__attributes,
    __attributes = cls.__attributes, __methods = cls.__attributes,
  }
  setmetatable(obj, obj)
  obj.__newindex = class.set
  obj.__object = true
  obj.__name = cls.__name
  obj.__inherits = cls.__inherits
  obj.__instance = true
  obj.__class = cls
  obj.__index = cls

  if defaults then
    for key, value in pairs(defaults) do
      obj[key] = value
    end
  end

  if cls.initialize then
    cls.initialize(obj, ...)
  else
    class.super(obj, ...)
  end

  return obj
end

function class:__call(name, inherits, defaults)
  if inherits and inherits.__instance then
    inherits = inherits.__class
  end

  local cls = {
    __attributes = {}, __methods = {},
    __metaattributes = {__metaattributes = true, __metamethods = true},
    __metamethods = {},
  }

  setmetatable(cls, cls)

  cls.__newindex = class.set
  cls.__object = true
  cls.__instance = false
  cls.__name = name
  cls.__inherits = inherits
  cls.__index = inherits

  if inherits then
    for key, _ in pairs(inherits.__attributes) do
      cls.__attributes[key] = true
    end

    for key, _ in pairs(inherits.__methods) do
      cls.__methods[key] = true
    end

    for key, _ in pairs(inherits.__metaattributes) do
      cls.__metaattributes[key] = true
    end

    for key, _ in pairs(inherits.__metamethods) do
      cls.__metamethods[key] = true
    end
  end

  function cls:new(...)
    return class.create_instance(cls, defaults, ...)
  end

  cls.__call = cls.new

  if defaults then
    for key, value in pairs(defaults) do
      class.set(cls, key, value)
    end
  end

  setmetatable(cls, cls)
  return cls
end

class.isa = class.inherits

return class
