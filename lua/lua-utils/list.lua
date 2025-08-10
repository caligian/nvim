local copy = require 'lua-utils.copy'
local list = {}

list.concat = table.concat
list.collapse = table.concat
list.join = table.concat
list.insert = table.insert
list.remove = table.remove

function list.max(x)
  return math.max(unpack(x))
end

function list.min(x)
  return math.min(unpack(x))
end

function list.empty(x)
  return #x == 0
end

list.is_empty = list.empty

function list.seq_along(x)
  local res = {}
  for i, _ in ipairs(x) do
    res[i] = i
  end
  return res
end

function list.length(x)
  return #x
end

list.len = list.length

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

function list.filter(x, f, mapper)
  local res = {}
  for i=1, #x do
    if f(x[i]) then
      if mapper then
        res[#res+1] = mapper(x[i])
      else
        res[#res+1] = x[i]
      end
    end
  end
  return res
end

function list.map(x, f)
  local res = {}
  for i=1, #x do
    res[i] = f(x[i])
  end
  return res
end

function list.nth(x, n)
  return x[n]
end

function list.is_list(t)
  local i = 0
  for _ in pairs(t) do
    i = i + 1
    if t[i] == nil then return false end
  end
  return true
end

function list.pop(x, pos)
  pos = pos or #x
  local v = x[pos]

  if v ~= nil then
    table.remove(x, pos)
    return v, x
  end

  return nil, x
end

function list.popn(x, pos, times)
  pos = pos or #x
  times = times or 1
  local out = {}

  for _ = 1, times do
    list.push(out, (list.pop(x, pos)))
  end

  return x, out
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

function list.each(x, f)
  for i=1, #x do
    f(x[i])
  end
end

function list.zip2(x, y, mkdefault)
  mkdefault = mkdefault or function ()
    return false
  end
  local res = {}
  local x_len = #x

  for i=1, x_len do
    local x_value = x[i]
    local y_value = y[i]
    if y_value == nil then y_value = mkdefault() end
    res[i] = {x_value, y_value}
  end

  return res
end

function list.filter_unless(x, f, mapper)
  local out = {}

  for i = 1, #x do
    if not f(x[i]) then
      if mapper then
        list.push(out, mapper(x[i]))
      else
        list.push(out, x[i])
      end
    end
  end

  return out
end

function list.butlast(t, n)
  n = n or 1
  local len = #t
  local new = {}

  for i = 1, len - n do
    new[i] = t[i]
  end

  return new
end

function list.head(t, n)
  n = n or 1
  local out = {}

  for i = 1, n do
    out[i] = t[i]
  end

  return out
end

function list.tail(t, n)
  n = n or 1
  local len = #t

  if n == 1 then
    return { t[len] }
  end

  n = n or 1
  local out = {}

  for i = len - (n - 1), len do
    list.push(out, t[i])
  end

  return out
end

function list.rest(t, n)
  n = n or 1
  local out = {}

  for i = n + 1, #t do
    list.push(out, t[i])
  end

  return out
end

function list.reduce(x, acc, f)
  for i = 1, #x do
    acc = f(x[i], acc)
  end

  return acc
end

function list.last(x)
  return x[#x]
end

function list.zip(...)
  local args = { ... }
  local lens = list.map(args, list.length)
  local minlen = list.min(lens)
  local out = {}

  local function zip(start)
    if start > minlen then
      return
    end

    local current = out[start]
    if not current then
      list.push(out, {})
      current = list.last(out)
    end

    for j = 1, #args do
      local v = args[j][start]
      list.push(current, v)
    end

    zip(start + 1)
  end

  zip(1)
  return out
end

function list.zip_longest(...)
  local args = { ... }
  local _, fillvalue = list.pop(args)
  local lens = list.map(args, list.length)
  local maxlen = list.max(lens)
  local out = {}

  local function zip(start)
    start = start or 1
    if start > maxlen then
      return
    end
    local current = out[start]
    if not current then
      list.push(out, {})
      current = list.last(out)
    end

    for j = 1, #args do
      local v = args[j][start]
      if v == nil then
        v = fillvalue
      end
      list.push(current, v)
    end

    zip(start + 1)
  end

  zip()
  return out
end

function list.shift(x)
  local pos = 1
  if x[pos] == nil then
    return x
  end
  return list.pop(x, pos)
end

function list.shiftn(x, times)
  local out = {}
  local len = #x

  if len == 0 then
    return nil, x
  end

  times = math.min(len, times or 1)
  for _ = 1, times or 1 do
    list.push(out, (list.pop(x, 1)))
  end

  return out, x
end

function list.all(t, f)
  for i = 1, #t do
    if f then
      if not f(t[i]) then
        return false
      end
    elseif not t[i] then
      return false
    end
  end

  return true
end

function list.some(t, f)
  for i = 1, #t do
    if f then
      if f(t[i]) then
        return true
      end
    elseif t[i] then
      return true
    end
  end

  return false
end

function list.partition(x, fun_or_num)
  if type(fun_or_num) ~= 'number' then
    local result = { {}, {} }
    for i = 1, #x do
      if fun_or_num(x[i]) then
        list.append(result[1], x[i])
      else
        list.append(result[2], x[i])
      end
    end
    return result
  end

  local len = #x
  local chunk_size = math.ceil(len / fun_or_num)
  local result = {}

  for i = 1, len, chunk_size do
    list.push(result, {})
    local curr = list.last(result)
    for j = 1, chunk_size do
      list.push(curr, x[i + j - 1])
    end
  end

  return result
end

function list.chunk(x, chunk_size)
  chunk_size = chunk_size or 2
  list.partition(x, chunk_size)
end

local function bsearch(arr, elem, cmp, i, j)
  i = i or 1
  j = j or #arr

  if j < i then
    return
  end

  local mid = i + math.floor((j - i) / 2)
  local mid_elem = arr[mid]
  local result = cmp(elem, mid_elem)

  if result == 0 then
    return mid, mid_elem
  elseif result == 1 then
    return bsearch(arr, elem, cmp, i, mid - 1)
  elseif result == -1 then
    return bsearch(arr, elem, cmp, mid + 1, j)
  end
end

function list.bsearch(arr, elem, cmp)
  cmp = cmp or function (x, y)
    if x == y then
      return 0
    elseif x > y then
      return -1
    else
      return 1
    end
  end
  return bsearch(arr, elem, cmp)
end

list.cdr = list.rest
list.append = list.push
list.size = list.length

function list.copy(x, deep)
  if deep then
    return copy.deep(x, {})
  else
    return copy.copy(x, {})
  end
end

function list.deep_copy(x)
  return copy.deep(x)
end

return list
