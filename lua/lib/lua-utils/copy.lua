local copy = {}

--- Shallow copy table
--- @param x table src table
--- @param res? table dest table
--- @return table
function copy.copy(x, res)
  res = res or {}
  local mt = getmetatable(x)

  for key, value in pairs(x) do
    res[key] = value
  end

  if mt then
    setmetatable(res, mt)
  end

  return res
end

--- Deep copy table. Simple copies circular references
--- @param x table src table
--- @param res? table dest table
--- @return table
function copy.deep(x, res)
  local mt = getmetatable(x)
  res = res or {}
  local cache = {}
  cache[x] = true

  if mt then
    setmetatable(res, mt)
  end

  for key, value in pairs(x) do
    if type(value) == 'table' then
      if cache[value] then
        res[key] = value
      else
        res[key] = {}
        cache[value] = true
        copy.deep(value, res[key])
      end
    else
      res[key] = value
    end
  end

  return res
end

return copy
