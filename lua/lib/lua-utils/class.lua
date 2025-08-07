local types = require('lib.lua-utils.type')
local validate = require('lib.lua-utils.validate')
local class = {}

setmetatable(class, class)

class.child_of = types.inherits
class.is_instance = types.instance
class.is_class = types.class
class.is_object = types.object
class.inherits = types.inherits

--- Is x a parent of y?
function class.parent_of(x, y)
  return class.child_of(y, x)
end

function class.super(cls, ...)
  local function find_init(x)
    if types.instance(x) then
      x = x.__class
    elseif x.initialize then
      return x.initialize
    elseif not x.__inherits then
      return
    end

    x = x.__inherits
    if not x then
      return
    elseif x.initialize then
      return x.initialize
    else
      return find_init(x)
    end
  end

  local init = find_init(cls)
  if init then
    init(cls, ...)
  end
end

function class.attributes(x)
  if not types.table(x) then
    return
  end

  local res = {}
  for key, value in pairs(x) do
    if not key:match('^__') and class[key] == nil then
      res[key] = value
    end
  end

  return res
end

function class.get_instance_methods(x, invert)
  local res = class.attributes(x)
  if not res then
    return res
  end

  local methods = {}
  for key, value in pairs(res) do
    local test = types.callable(value) and not class.isclass(value)
    test = ifelse(invert, not test, test)
    if test then
      methods[key] = value
    end
  end

  return methods
end

function class.include(self, from)
  for key, value in pairs(from) do
    if self[key] == nil then self[key] = value end
  end

  return self
end

function class.new(name, inherits)
  return class(name, inherits)
end

function class:__call(name, inherits)
  validate.name(name, 'string')
  validate.opt_inherits(inherits, types.class)

  if class.is_instance(inherits) then
    inherits = inherits.__class
  end

  local cls = {
    __instance = false,
    __name = name,
    __inherits = inherits,
    include = class.include,
    get_instance_methods = class.get_instance_methods,
    attributes = class.attributes,
    child_of = class.child_of,
    parent_of = class.parent_of,
    is_instance = class.is_instance,
    get_class = class.get_class,
    inherits = class.inherits,
    new = function (cls_self, ...)
      local obj = {
        __name = name,
        __instance = true,
        __class = cls_self,
        __index = cls_self,
        __inherits = inherits,
        include = class.include,
        get_instance_methods = class.get_instance_methods,
        attributes = class.attributes,
        child_of = class.child_of,
        parent_of = class.parent_of,
        is_instance = class.is_instance,
        get_class = class.get_class,
        inherits = class.inherits,
        create_instance_method = function (obj_self, method)
          if not obj_self[name] then
            return false
          else
            return function (...)
              return method(obj_self, ...)
            end
          end
        end
      }

      setmetatable(obj, obj)

      if cls_self.initialize then
        cls_self.initialize(obj, ...)
      else
        class.super(obj, ...)
      end

      return obj
    end,
  }

  setmetatable(cls, cls)

  cls.__call = cls.new
  cls.__index = inherits

  return cls
end

return class
