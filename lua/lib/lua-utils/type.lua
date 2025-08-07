require 'lib.lua-utils.utils'
local list = require('lib.lua-utils.list')
local types = {}

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

types['function'] = types.fun

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
  elseif not list.is_list(x) then
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
  elseif not types.fun(x) and not types.table(x) then
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

function types.type(x)
  if types.object(x) then
    return 'object'
  elseif types.pure_list(x) then
    return 'pure_list'
  elseif types.pure_dict(x) then
    return 'pure_dict'
  elseif types.list(x) then
    return 'list'
  elseif types.dict(x) then
    return 'dict'
  elseif types.fun(x) then
    return 'function'
  elseif types.callable(x) then
    return 'callable'
  else
    return type(x)
  end
end

function types.is(child, parent)
  if child == nil and parent == nil then
    return true
  elseif types.string(parent) then
    if parent == 'pure_list' then
      return types.pure_list(child)
    elseif parent == 'pure_dict' then
      return types.pure_dict(child)
    elseif parent == 'list' then
      return types.list(child)
    elseif parent == 'dict' then
      return types.dict(child)
    elseif parent == 'callable' then
      return types.callable(child)
    elseif parent == 'class' then
      return types.class(child)
    elseif parent == 'instance' then
      return types.instance(child)
    elseif parent == 'object' then
      return types.object(child)
    else
      local ok = type(child) == parent
      if not ok then
        return false, sprintf('expected %s, got %s', parent, child)
      else
        return true
      end
    end
  elseif types.object(parent) then
    local ok, msg = types.object(child)
    if not ok then
      return false, msg
    else
      return child:inherits(parent)
    end
  elseif types.table(parent) then
    local ok, msg = types.table(child)
    if not ok then
      return false, msg
    else
      return types.includes(child, parent)
    end
  elseif types.fun(parent) then
    return parent(child)
  elseif types.callable(parent) then
    return parent(child)
  else
    local parent_type = types.type(parent)
    local child_type = types.type(child)
    if parent_type ~= child_type then
      return false, sprintf(
        'expected %s, got (%s) %s',
        parent_type,
        child_type,
        child
      )
    else
      return true
    end
  end
end

types.assert = {}
setmetatable(types.assert, types.assert)

--- Assert type
--- @overload fun(x: any, cond: any, name?: string)
function types.assert:__call(x, cond, name)
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

function types.assert:__index(name)
  return function (x, cond)
    return types.assert(x, cond, name)
  end
end

function types.inherits(child, parent)
  if child == nil and parent == nil then
    return true
  elseif child == nil then
    return false, 'child: expected object, got nothing'
  elseif parent == nil then
    return false, 'parent: expected object, got nothing'
  end

  local ok, msg = types.object(child)
  if not ok then return false, 'child: ' .. msg end

  ok, msg = types.object(parent)
  if not ok then return false, 'parent: ' .. msg end

  if child == parent then
    return true
  elseif child.__inherits ~= nil and child.__inherits == parent then
    return true
  end

  if child.__instance then child = child.__class end
  if parent.__instance then parent = parent.__class end
  local inherits = child.__inherits

  while true do
    if inherits == nil then
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

    msg = sprintf('error: \n%s', msgs)
    return false, msg
  end
end

function types.is_union(x, ...)
  local ok, msg
  local msgs = {}
  local signature = {...}

  for _, sig in ipairs(signature) do
    ok, msg = types.is(x, sig)
    if ok then
      return true
    else
      list.append(msgs, msg)
    end
  end

  msg = sprintf('error: \n%s', msgs)
  return false, msg
end

function types.is_optional(x, cond)
  if x == nil then
    return true
  else
    return types.is(x, cond)
  end
end

types.is_opt = types.is_optional

function types.list_of(x, what, assert_)
  local ok, msg = types.list(x)
  if not ok then return false, msg end

  for i=1, #x do
    ok, msg = types.is(x[i], what)
    if not ok then
      msg = msg or sprintf('type mismatch (%s)', x)
      if assert_ then
        error(sprintf('error @ element %d: %s', i, msg))
      else
        return false, sprintf('error @ element %d: %s', i, msg)
      end
    end
  end
  return true
end

function types.dict_of(x, what, assert_)
  local ok, msg = types.list(x)
  if not ok then return false, msg end

  for key, value in pairs(x) do
    ok, msg = types.is(value, what)
    if not ok then
      msg = msg or sprintf('type mismatch (%s)', x)
      if assert_ then
        error(sprintf('error @ element %s: %s', key, msg))
      else
        return false, sprintf('error @ element %s: %s', key, msg)
      end
    end
  end
  return true
end

function types.table_of(x, key_f, value_f, assert_)
  local ok, msg = types.table(x)
  if not ok then return false, msg end

  for key, value in pairs(x) do
    ok, msg = types.is(key, key_f)
    if not ok then
      msg = msg or 'type mismatch'
      msg = sprintf('error @ key %s: ', key, msg)
      if assert_ then
        error(msg)
      else
        return false, msg
      end
    end

    ok, msg = types.is(value, value_f)
    if not ok then
      msg = msg or 'type mismatch'
      msg = sprintf('error @ value @ key %s: %s', key, msg)
      if assert_ then
        error(msg)
      else
        return false, msg
      end
    end
  end

  return true
end

return types
