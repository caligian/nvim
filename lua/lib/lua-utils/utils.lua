local tuple = require('lib.lua-utils.tuple')
local list = require('lib.lua-utils.list')

function ifelse(cond, when_true, when_false)
  if cond then
    return when_true
  else
    return when_false
  end
end

function unless(cond, when_false, when_true)
  if not cond then
    return when_false
  else
    return when_true
  end
end

function apply(f, args, should_pcall)
  if should_pcall then
    local ok, msg = pcall(f, unpack(args))
    if ok then
      return msg
    end
  else
    return f(unpack(args))
  end
end

function partial(f, ...)
  local args = tuple.pack(...)
  return function(...)
    list.extend(args, tuple.pack(...))
    return f(unpack(args))
  end
end

function rpartial(f, ...)
  local args = tuple.pack(...)
  return function(...)
    list.extend(tuple.pack(...), args)
    return f(unpack(args))
  end
end

function sprintf(fmt, ...)
  local args = tuple.pack(...)

  for i=1, #args do
    local x = args[i]
    local _type = type(x)
    if _type ~= "string" and type(_type) ~= "number" then
      args[i] = vim.inspect(args[i])
    end
  end

  return apply(string.format, list.extend({fmt}, args))
end

function printf(fmt, ...)
  local args = tuple.pack(...)
  list.unpush(args, fmt)
  local s = apply(sprintf, args)
  print(s)
end

function ifnonnil(obj, if_nonnil, if_nil)
  return ifnil(obj, if_nil, if_nonnil)
end

function ifnil(obj, if_nil, if_nonnil)
  if if_nonnil == nil then
    if_nonnil = obj
  end
  if obj == nil then
    return if_nil
  else
    return if_nonnil
  end
end

function thread(obj, ...)
  local res = obj
  local map = tuple.pack(...)

  if #map == 0 then
    return res
  end

  res = {map[1](res)}
  for i=2, #map do
    res = {map[i](unpack(res))}
  end

  return unpack(res)
end

function identity(...)
  return ...
end

function pprint(fmt, ...)
  local args = tuple.pack(...)
  printf(fmt or '%s', unpack(args))
end

function pp(...)
  local args = tuple.pack(...)
  if #args == 0 then
    return
  else
    printf('%s', args)
  end
end

function paste0(...)
  local args = tuple.pack(...)
  for i=1, #args do args[i] = tostring(args[i]) end
  return table.concat(args, '')
end

inspect = vim.inspect
dump = inspect
