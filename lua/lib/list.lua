local list = {}
user_config.list = list
list.concat = table.concat
list.collapse = table.concat
list.join = table.concat
list.insert = table.insert
list.remove = table.remove
list.length = vim.tbl_count
list.empty = vim.tbl_isempty
list.seq_along = vim.tbl_keys
list.maxn = table.maxn

function list.reverse(x)
  local res = {}
  local ind = 1

  for i=#x, 1, -1 do
    res[ind] = x[i]
    ind = ind + 1
  end

  return res
end

function list.push(x, ...)
  for _, arg in ipairs({...}) do
    table.insert(x, arg)
  end

  return x
end


function list.unpush(x, ...)
  for _, arg in ipairs(list.reverse({...})) do
    table.insert(x, 1, arg)
  end

  return x
end

function list.extend(x, ...)
  for _, arg in ipairs({...}) do
    if type(arg) == 'table' then
      for i=1, #arg do
        list.append(x, arg[i])
      end
    else
      list.append(x, arg)
    end
  end

  return x
end

function list.seq(_i, _j, by)
  by = by or 1
  local res = {}
  local ind  = 1

  for i=_i, _j, by do
    res[ind] = i
    ind = ind + 1
  end

  return res
end

function list.cat(...)
  local res = {}
  for _, x in ipairs({...}) do list.extend(res, x) end
  return res
end

function list.as_list(x, force)
  if force then
    return {x}
  elseif type(x) == 'table' then
    return x
  else
    return {x}
  end
end

function list.extract(x)
  local res = {}
  for i=1, #x do res[i] = x[i] end
  return res
end

function list.take(x, n, filter, map)
  local res = {}
  local len = #x
  if n > len then return x end
  for i=1, n do res[i] = x[i] end

  if filter then res = list.filter(x, filter) end
  if map then res = list.map(x, map) end

  return res
end

function list.map(x, f)
  return vim.tbl_map(f, x)
end

function list.filter(x, f)
  return vim.tbl_filter(f, x)
end

function list.nth(x, n)
  return x[n]
end

function list.is_list(x)
  return vim.isarray(x)
end

function list.compare(x, y, res)
  res = res or {}
  local limit = math.min(#x, #y)
  for i=1, limit do
    if type(x[i]) == 'table' and type(y[i]) == 'table' then
      res[i] = {}
      list.compare(x[i], y[i], res[i])
    else
      res[i] = x[i] == y[i]
    end
  end
  return res
end

function list.equal(x, y, cmp)
  cmp = cmp or function(a, b) return a == b end
  for key, value in pairs(x) do
    if type(value) == 'table' and type(y[key]) == 'table' then
      local ok = list.equal(value, y[key], cmp)
      if not ok then return false end
    elseif not cmp(value, y[key]) then
      return false
    end
  end
  return true
end

function list.set(x, ks, value)
  local _x = x
  for i=1, #ks-1 do
    local k = ks[i]
    local v = x[k]
    if type(v) == 'table' then
      x = v
    else
      return
    end
  end

  x[ks[#ks]] = value
  return _x, x
end

function list.has(x, ks)
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

function list.get(x, ks, map)
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

function list.has_path(x, ks)
  return type((list.get(x, ks))) == 'table'
end

function list.slice(x, i, j)
  local res = {}
  local len = #x
  i = i < 0 and len + i or i
  j = j < 0 and len + j or j

  if i > j then
    return
  end

  local ind = 1
  for _i=i, j do
    res[ind] = x[_i]
    ind = ind + 1
  end

  return res
end

function list.sort(x, cmp)
  table.sort(x, cmp)
  return x
end

function list.contains(x, value, cmp)
  cmp = cmp or function(a, b) return a == b end
  for key, x_value in ipairs(x) do
    if type(x_value) == 'table' then
      local _key, _x = list.contains(x_value, value, cmp)
      if _key then return _key, _x end
    elseif cmp(x_value, value) then
      return key, x
    end
  end
end

function list.flatten(x, res)
  res = res or {}
  for i=1, #x do
    local v = x[i]
    if type(v) == 'table' then
      list.flatten(v, res)
    else
      res[#res+1] = v
    end
  end
  return res
end

list.append = list.push
list.size = list.length

return list
