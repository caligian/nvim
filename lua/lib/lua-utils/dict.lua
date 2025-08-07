local copy = require('lib.lua-utils.copy')
local dict = {}

function dict.keys(x)
  local ks = {}
  local i = 0

  for key, _ in pairs(x) do
    i = i + 1
    ks[i] = key
  end

  return ks
end

function dict.values(x)
  local vs = {}
  local i = 0

  for _, value in pairs(x) do
    i = i + 1
    vs[i] = value
  end

  return vs
end

function dict.size(x)
  local n = 0
  for _ in pairs(x) do
    n = n + 1
  end
  return n
end

function dict.empty(x)
  for _ in pairs(x) do return false end
  return true
end

dict.is_empty = dict.empty

function dict.set(x, ks, value, force)
  local _x = x
  for i=1, #ks-1 do
    local k = ks[i]
    local v = x[k]
    if type(v) == 'table' then
      x = v
    elseif not force then
      return
    else
      x[k] = {}
      x = x[k]
    end
  end

  x[ks[#ks]] = value
  return _x
end

function dict.force_set(x, ks, value)
  return dict.set(x, ks, value, true)
end

function dict.has(x, ks)
  for i=1, #ks-1 do
    local k = ks[i]
    local v = x[k]
    if type(v) ~= 'table' then
      return false
    else
      x = v
    end
  end
  return x[ks[#ks]] ~= nil
end

function dict.get(x, ks, map)
  for i=1, #ks-1 do
    local k = ks[i]
    local v = x[k]
    if type(v) ~= 'table' then
      return
    else
      x = v
    end
  end

  local v = x[ks[#ks]]
  if v ~= nil then
    if map then return map(v) end
    return v, x
  end
end

function dict.has_path(x, ks)
  return type((dict.get(x, ks))) == 'table'
end

function dict.contains(x, value, cmp)
  cmp = cmp or function(a, b) return a == b end
  for key, x_value in pairs(x) do
    if type(x_value) == 'table' then
      local _key, _x = dict.contains(x_value, value, cmp)
      if _key then return _key, _x end
    elseif cmp(x_value, value) then
      return key, x
    end
  end
end

function dict.map(x, f)
  local res = {}
  for key, value in pairs(x) do
    res[key] = f(key, value)
  end
  return res
end

function dict.filter(x, f, map)
  local res = {}
  for key, value in pairs(x) do
    if f(key, value) then
      res[key] = map and map(value) or value
    end
  end
  return res
end

function dict.compare(x, y, cmp, res)
  cmp = cmp or function (a, b) return a == b end
  res = res or {}

  for key, value in pairs(x) do
    if type(value) == 'table' and type(y[key]) == 'table' then
      res[key] = {}
      dict.compare(value, y[key], cmp, res[key])
    else
      res[key] = cmp(x[key], y[key])
    end
  end

  return res
end

function dict.equal(x, y, cmp)
  cmp = cmp or function(a, b) return a == b end

  for key, value in pairs(x) do
    if type(value) == 'table' and type(y[key]) == 'table' then
      local ok = dict.equal(value, y[key], cmp)
      if not ok then return false end
    elseif not cmp(value, y[key]) then
      return false
    end
  end

  return true
end

function dict.is_dict(x)
  local n = 0
  for _ in pairs(x) do n = n + 1 end
  return n ~= #x
end

function dict.take(x, ks, filter, map)
  local res = {}
  for _, k in ipairs(ks) do res[k] = x[k] end

  if filter then res = dict.filter(x, filter) end
  if map then res = dict.map(x, map) end

  return res
end

dict.select = dict.take

function dict.flatten(x, collapse, res, last_key)
  collapse = collapse or '.'
  res = res or {}
  local function create_key(k)
    if last_key then
      return last_key .. collapse .. k
    else
      return k
    end
  end

  for key, value in pairs(x) do
    if type(value) == 'table' then
      dict.flatten(value, collapse, res, create_key(key))
    else
      res[create_key(key)] = value
    end
  end

  return res
end

local function join_tables(x, y, force)
  for key, value in pairs(y) do
    local x_value = x[key]
    local y_value = value

    if x_value == nil then
      x[key] = y_value
    elseif type(y_value) == 'table' then
      if type(x_value) == 'table'  then
        join_tables(x_value, y_value, force)
      elseif force then
        x[key] = y_value
      end
    else
      x[key] = y_value
    end
  end
end

function dict.merge(x, y, force)
  join_tables(x, y, force)
  return x
end

function dict.force_merge(x, y)
  return dict.merge(x, y, true)
end

function dict.set_unless(x, ks, value, force)
  if not dict.has(x, ks) then
    force = ifnil(force, true)
    return dict.set(x, ks, value, force)
  end
end

function dict.from_keys(ks, default_fn)
  local res = {}
  for i=1, #ks do
    res[ks[i]] = default_fn()
  end
  return res
end

function dict.each(x, callback)
  for key, value in pairs(x) do
    callback(key, value)
  end
end

function dict.items(x)
  local res = {}
  local ind = 1
  for key, value in pairs(x) do
    res[ind] = {key, value}
    ind = ind + 1
  end
  return res
end

function dict.from_zipped(zipped)
  local out = {}
  dict.each(zipped, function(z)
    out[z[1]] = z[2]
  end)
  return out
end

function dict.partition(x, fn)
  local result = { {}, {} }
  for key, value in pairs(x) do
    if fn(value) then
      result[1][key] = value
    else
      result[2][key] = value
    end
  end
  return result
end

function dict.reduce(x, acc, f)
  for key, value in pairs(x) do
    acc = f(key, value, acc)
  end
  return acc
end

function dict.all(t, f)
  for key, value in pairs(t) do
    if f then
      if not f(key, value) then
        return false
      end
    elseif not value then
      return false
    end
  end

  return true
end

function dict.some(t, f)
  for key, value in pairs(t) do
    if f then
      if f(key, value) then
        return true
      end
    elseif value then
      return true
    end
  end

  return false
end

function dict.update(x, ks, default, fn)
  local len = #ks
  local tmp = x

  for i = 1, len - 1 do
    if type(tmp[ks[i]]) == "table" then
      tmp = tmp[ks[i]]
    else
      return
    end
  end

  local value
  local has = tmp[ks[len]]

  if has ~= nil then
    if fn then
      value = fn(has)
    else
      value = has
    end
  elseif default ~= nil then
    value = default
  else
    value = true
  end

  tmp[ks[len]] = value

  return x, tmp
end

function dict.pop1(x, ks)
  local value, level = dict.get(x, ks)
  if value then
    level[ks[#ks]] = nil
  end
  return value
end

function dict.pop(x, ...)
  local res = {}
  local args = {...}
  local ind = 1

  for i=1, #args do
    local ks = args[i]
    local value = dict.pop(x, ks)
    res[ind] = value
    ind = ind + 1
  end

  return res
end

function dict.copy(x, deep)
  if deep then
    return copy.deep(x, {})
  else
    return copy.copy(x, {})
  end
end

function dict.deep_copy(x)
  return dict.copy(x, true)
end

return dict
