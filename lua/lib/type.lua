require 'lib.utils'

local types = {_base = {}}
local list = require('lib.list')

function types.userdata(x)
  if x == nil then
    return false, 'expected userdata, got nothing'
  else
    local ok
    ok = type(x) == 'userdata'
    if not ok then return false, sprintf('expected userdata, got %s', x) end
    return true
  end
end

function types.fun(x)
  if x == nil then
    return false, 'expected function, got nothing'
  else
    local ok
    ok = type(x) == 'function'
    if not ok then return false, sprintf('expected function, got %s', x) end
    return true
  end
end

function types.number(x)
  if x == nil then
    return false, 'expected number, got nothing'
  else
    local ok
    ok = type(x) == 'number'
    if not ok then return false, sprintf('expected number, got %s', x) end
    return true
  end
end

function types.table(x)
  if x == nil then
    return false, 'expected table, got nothing'
  else
    local ok
    ok = type(x) == 'table'
    if not ok then return false, sprintf('expected table, got %s', x) end
    return true
  end
end


function types.string(x)
  if x == nil then
    return false, 'expected string, got nothing'
  else
    local ok
    ok = type(x) == 'string'
    if not ok then return false, sprintf('expected string, got %s', x) end
    return true
  end
end


function types.boolean(x)
  if x == nil then
    return false, 'expected boolean, got nothing'
  else
    local ok
    ok = type(x) == 'boolean'
    if not ok then return false, sprintf('expected boolean, got %s', x) end
    return true
  end
end

function types.list(x)
  local ok, msg = types.table(x)
  if not ok then
    return false, msg
  elseif not vim.isarray(x) then
    return false, sprintf('expected list, got dict: %s', x)
  else
    return true
  end
end

function types.dict(x)
  local ok, msg = types.table(x)
  if not ok then
    return false, msg
  elseif types.list(x) then
    return false, sprintf('expected dict, got list: %s', x)
  else
    return true
  end
end

function types.callable(x)
  if x == nil then
    return false, 'expected function|callable, got nothing'
  elseif not types.fun and not types.table(x) then
    return false, sprintf('expected function | callable, got %s', x)
  elseif types.fun(x) then
    return true
  elseif types.table(x) then
    local mt = getmetatable(x)
    if mt and mt.__call then
      return types.callable(mt.__call)
    else
      return false, sprintf('expected table with __call, got %s', x)
    end
  end
end

function types.has_metatable(x)
  local ok, msg = types.table(x)
  if not ok then return false, msg end

  local mt = getmetatable(x)
  if not mt then return false, sprintf('expected table with metatable, got %s', x) end

  return true
end

function types.pure_table(x)
  if x == nil then
    return false, 'expected table, got nothing'
  else
    local ok, msg = types.table(x)
    if not ok then
      return false, msg
    elseif types.has_metatable(x) then
      return false, sprintf('expected table without metatable, got %s', x)
    else
      return true
    end
  end
end

function types.pure_dict(x)
  if x == nil then
    return false, 'expected dict, got nothing'
  else
    local ok, msg = types.dict(x)
    if not ok then
      return false, msg
    elseif types.has_metatable(x) then
      return false, sprintf('expected dict without metatable, got %s', x)
    else
      return true
    end
  end
end

function types.pure_list(x)
  if x == nil then
    return false, 'expected list, got nothing'
  else
    local ok, msg = types.list(x)
    if not ok then
      return false, msg
    elseif types.has_metatable(x) then
      return false, sprintf('expected list without metatable, got %s', x)
    else
      return true
    end
  end
end

function types.class(x)
  local ok, msg = types.table(x)
  if not ok then return false, msg end

  ok, msg = types.has_metatable(x)
  if not ok then return false, msg end

  ok = x.__name ~= nil
  if not ok then
    return false, sprintf('expected __name for class, got %s', x)
  elseif x.__instance then
    return false, sprintf('expected class, got instance %s', x)
  else
    return true
  end
end

function types.instance(x)
  local ok, msg = types.table(x)
  if not ok then return false, msg end

  ok, msg = types.has_metatable(x)
  if not ok then return false, msg end

  ok = x.__name ~= nil
  if not ok then
    return false, sprintf('expected __name for class, got %s', x)
  elseif not x.__instance then
    return false, sprintf('expected __instance for object, got %s', x)
  else
    return true
  end
end

function types.includes(x, y)
  for key, _ in pairs(x) do
    if y[key] == nil then
      return false, sprintf('expected x to have attribute %s', key)
    end
  end
  return true
end

function types.object(x)
  if x == nil then
    return false, 'expected object, got nothing'
  elseif types.class(x) then
    return true
  elseif types.instance(x) then
    return true
  else
    return false, sprintf('expected class or instance, got %s', x)
  end
end

function types.identical(x, y)
  return type(x) == type(y)
end

function types.is(child, parent)
  if child == nil and parent == nil then
    return true
  elseif types.string(parent) then
    local ok = type(child) == parent
    if not ok then
      return false, sprintf('expected %s, got %s', parent, child)
    else
      return true
    end
  elseif types.object(child) and types.identical(child, parent) then
    return child:inherits(parent)
  elseif types.table(child) and types.identical(child, parent) then
    return types.includes(child, parent)
  elseif types.callable(parent) then
    return parent(child)
  elseif child ~= parent then
    return false, sprintf('expected %s, got %s', type(parent), child)
  else
    return true
  end
end

function types.assert(x, cond, name)
  if name then
    local ok, msg = types.string(name)
    if not ok then error(sprintf('%s: %s', name, msg)) end
  end

  local ok, msg = types.is(x, cond)
  if not ok then
    msg = msg or ''
    if name then
      error(name .. ': ' .. msg)
    else
      error(msg)
    end
  else
    return true
  end
end

function types.inherits(child, parent)
  local ok, msg = types.table(child)
  if not ok then return false, 'child: ' .. msg end

  ok, msg = types.table(parent)
  if not ok then return false, 'parent: ' .. msg end

  if not child.__inherits then
    return false, sprintf('child: lacks __inherits attribute, likely not an object: %s', child)
  elseif not parent.__inherits then
    return false, sprintf('parent: lacks __inherits attribute, likely not an object: %s', parent)
  elseif child == parent or child.__inherits == parent then
    return true
  else
    local child_attribs = child:get_attributes()
    local parent_attribs = parent:get_attributes()
    table.sort(child_attribs)
    table.sort(parent_attribs)

    if vim.deep_equal(child_attribs, parent_attribs) then
      return true
    end
  end

  if child.__instance then child = child.__class end
  if parent.__instance then parent = parent.__class end
  local inherits = child.__inherits

  while true do
    if inherits == types._base then
      return false, sprintf('expected object %s, got %s', parent.__name, child)
    elseif inherits == parent then
      return true
    else
      inherits = inherits.__inherits
    end
  end
end

function types.optional(cond)
  return function(x)
    if x == nil then
      return true
    else
      return types.is(x, cond)
    end
  end
end

function types.get_name(x)
  if types.object(x) then
    return x.__name
  elseif types.list(x) then
    return 'list'
  else
    return type(x)
  end
end

function types.union(...)
  local signature = {...}
  return function (x)
    local ok, msg
    local msgs = {}
    for _, sig in ipairs(signature) do
      ok, msg = types.is(x, sig)
      if ok then
        return true
      else
        list.append(msgs, msg)
      end
    end

    msg = sprintf('error: %s', msgs)
    return false, msg
  end
end

function types.list_of(what)
  return function(x)
    local ok, msg = types.list(x)
    if not ok then return false, msg end

    for i=1, #x do
      ok, msg = types.is(x[i], what)
      if not ok then
        msg = msg or sprintf('type mismatch (%s)', x)
        return false, sprintf('error @ element %d: %s', i, msg)
      end
    end
    return true
  end
end

function types.dict_of(what)
  return function(x)
    local ok, msg = types.list(x)
    if not ok then return false, msg end

    for key, value in pairs(x) do
      ok, msg = types.is(value, what)
      if not ok then
        msg = msg or sprintf('type mismatch (%s)', x)
        return false, sprintf('error @ key %s: %s', key, msg)
      end
    end
    return true
  end
end

function types.table_of(key_f, value_f)
  return function(x)
    local ok, msg = types.table(x)
    if not ok then return false, msg end

    for key, value in pairs(x) do
      ok, msg = types.is(key, key_f)
      if not ok then
        msg = msg or 'type mismatch'
        return false, sprintf('error @ key %s: ', key, msg)
      end

      ok, msg = types.is(value, value_f)
      if not ok then
        msg = msg or sprintf('type mismatch (%s)', x)
        return false, sprintf('error @ key %s: %s', key, msg)
      end
    end
    return true
  end
end

types.default = {
  __name = 'default',
  __inherits = types._base,
  is = types.is,
  includes = types.includes,
  inherits = types.inherits,
  initialize = function(self, ...)
    local _ = {...}
    return self
  end,
  include = function(self, from)
    for key, value in pairs(from) do
      if self[key] == nil then
        self[key] = value
      end
    end
    return self
  end,
  get_attributes = function(self)
    local res = {}
    for key, _ in pairs(self) do
      local test = key ~= 'is' and key ~= 'includes'
      test = test and key ~= 'inherits' and key ~= 'attributes'
      test = test and key ~= 'include' and key ~= 'initialize' and key ~= 'includes'
      test = test and key ~= 'get_attributes' and key ~= 'attributes'
      test = test and not string.match(key, '^__')
      test = test and key ~= 'new'
      test = test and key ~= 'as_list'
      if test then res[#res+1] = key end
    end
    return res
  end,
  attributes = function(self)
    local res = {}
    for key, value in pairs(self) do
      local test = key ~= 'is' and key ~= 'includes'
      test = test and key ~= 'inherits' and key ~= 'attributes'
      test = test and key ~= 'include' and key ~= 'initialize' and key ~= 'includes'
      test = test and key ~= 'get_attributes' and key ~= 'attributes'
      test = test and not string.match(key, '^__')
      test = test and key ~= 'new'
      test = test and key ~= 'as_list' and key ~= 'as_dict'
      test = test and key ~= 'create_instance_method'
      if test then res[key] = value end
    end
    return res
  end,
  new = function(self, ...)
    local obj = {__instance = true}
    for key, value in pairs(self) do
      if key ~= 'new' then
        obj[key] = value
      end
    end

    obj.__class = self
    setmetatable(obj, obj)

    function obj:create_instance_method(...)
      return partial(self, ...)
    end

    obj:initialize(...)

    return obj
  end,
  as_list = function(self)
    local res = {}
    for i=1, #self do
      res[#res+1] = self[i]
    end
    return res
  end,
  as_dict = function(self)
    return self:attributes()
  end
}

types.default.__index = types._base
setmetatable(types.default, types.default)

function types.new(name, inherits)
  inherits = inherits or types.default
  local cls = { __name = name, __index = inherits, __inherits = inherits }
  setmetatable(cls, cls)

  for key, value in pairs(inherits:attributes()) do
    local _value = rawget(cls, key)
    if _value == nil then
      rawset(cls, key, value)
    end
  end

  return cls
end

--- type validator
local function validate_table(x, spec, prefix)
  for key, validator in pairs(spec) do
    local name = key
    local is_opt = string.match(name, '^opt_') or string.match(name, '^[?]')
    name = name:gsub('^opt_', '')
    name = name:gsub('^[?]', '')
    local value = x[name]

    if not (value == nil and is_opt) then
      local prefixed_key
      if prefix then
        prefixed_key = prefix .. '.' .. name
      else
        prefixed_key = name
      end

      if types.object(validator) or types.fun(validator) then
        types.assert(value, validator, prefixed_key)
      elseif type(validator) == 'table' then
        if type(value) == 'table' then
          validate_table(value, validator, prefixed_key)
        else
          error(sprintf('%s: expected table, got %s', value))
        end
      else
        types.assert(value, validator, prefixed_key)
      end
    end
  end
end

types.validate = {}
local validate = types.validate
setmetatable(types.validate, types.validate)

function validate:__call(specs)
  for key, spec in pairs(specs) do
    local name, validator, obj = key, spec[1], spec[2]
    local is_opt = string.match(key, '^opt_') or string.match(key, '^[?]')

    types.assert(
      validator,
      types.union(types.callable, types.string, types.table),
      name
    )

    if not (is_opt and obj == nil) then
      if types.string(validator) then
        local ok, msg = types.is(obj, validator)
        if not ok then
          msg = msg or 'assertion failed'
          msg = key .. ': ' .. msg
          error(msg)
        end
      elseif types.fun(validator) or types.object(obj) then
        types.assert(obj, validator, key)
      elseif types.table(validator) then
        local ok, msg = types.table(obj)
        if not ok then
          msg = key .. ': ' .. msg
          error(msg)
        end
        validate_table(obj, validator, key)
      end
    end
  end
end

function validate:__index(name)
  return function(obj, validator)
    validate {[name] = {validator, obj}}
  end
end

return types
