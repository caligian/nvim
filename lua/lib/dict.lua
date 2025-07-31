local dict = {}
dict.empty = vim.tbl_isempty
dict.size = vim.tbl_count
dict.values = vim.tbl_values
dict.keys = vim.tbl_keys

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

function dict.type(x)
	if vim.isarray(x) then
		return 'vector'
	else
		return 'table'
	end
end

function dict.compare(x, y, res)
  res = res or {}
  for key, value in pairs(x) do
    if type(value) == 'table' and type(y[key]) == 'table' then
      res[key] = {}
      dict.compare(value, y[key], res[key])
    else
      res[key] = x[key] == y[key]
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
  return type(x) == 'table' and not vim.isarray(x)
end

function dict.take(x, ks, filter, map)
  local res = {}
  for _, k in ipairs(ks) do res[k] = x[k] end

  if filter then res = dict.filter(x, filter) end
  if map then res = dict.map(x, map) end

  return res
end

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

function dict.merge(x, y, force)
  for key, value in pairs(y) do
    local x_value = x[key]
    if force then
      if type(value) == 'table' then
        if type(x_value) == 'table' then
          dict.merge(x_value, value, force)
        else
          x[key] = {}
          dict.merge(x[key], value, force)
        end
      else
        x[key] = value
      end
    elseif x_value == nil then
      if type(value) == 'table' then
        x[key] = vim.deepcopy(value)
      else
        x[key] = value
      end
    elseif type(x_value) == 'table' and type(value) == 'table' then
      dict.merge(x_value, value)
    end
  end

  return x
end

function dict.set_unless(x, ks, value)
  if not dict.has(x, ks) then
    return dict.set(x, ks, value, true)
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

return dict
