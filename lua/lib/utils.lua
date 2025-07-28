local list = require('lib.list')

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
  local args = {...}
  return function(...)
    list.extend(args, {...})
    return f(unpack(args))
  end
end

function rpartial(f, ...)
  local args = {...}
  return function(...)
    args = list.extend({...}, args)
    return f(unpack(args))
  end
end

function sprintf(...)
  local args = {...}
  for i=1, #args do
    local x = args[i]
    local _type = type(x)
    if _type ~= "string" and type(_type) ~= "number" then
      args[i] = vim.inspect(args[i])
    end
  end
  return apply(string.format, args)
end

function printf(...)
  print(sprintf(...))
end

function ifnonnil(obj, if_nonnil, if_nil)
  return ifnil(obj, if_nil, if_nonnil)
end

function ifnil(obj, if_nil, if_nonnil)
  if if_nonnil == nil then if_nonnil = obj end
  if obj == nil then
    return if_nil
  else
    return if_nonnil
  end
end

function thread(obj, ...)
  local res = obj
  local map = {...}
  for i=1, #map do
    if i ~= 1 then
      res = {map[i](unpack(res))}
    else
      res = {map[i](obj)}
    end
  end
  return unpack(res)
end

function identity(...)
  return ...
end

inspect = vim.inspect
