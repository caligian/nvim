local inspect = require 'inspect'
local dump = function (x)
  print(inspect(x, {indent = '  '}))
end

_G.user_config = {
  option = {}, keymap = {},
  autocmd = {}, augroup = {},
  repl = {}, terminal = {},
  filetype = {}, shell = false,
  buffer = {}, project = {},
  logs = {},
  utils = {},
}

local utils = user_config.utils
local root = user_config
local function to_list(x, force) 
  if force then
    return {x}
  elseif type(x) == 'table' then
    return x
  else
    return {x}
  end
end
local function assert_type(obj, expected, optional)
  if optional and obj == nil then
    return true
  elseif type(expected) == 'string' then
    expected = {expected}
  end

  local obj_type = type(obj)
  obj_type = obj_type == nil and 'nil' or obj_type

  for i=1, #expected do
    if obj_type == expected[i] then
      return true
    end
  end

  local msg = table.concat(expected, ", ")
  error('obj: expected any of ' .. msg .. ', got ' .. obj_type)
end

function utils.update(overrides)
  local function merge(child, parent)
    for key, value in pairs(parent) do
      if key ~= 'state' then
        if type(value) == 'table' then
          merge(child, value)
        else
          child[key] = value
        end
      end
    end
  end

  if overrides then
    merge(root, overrides)
  end

  return root
end

function utils.get(keys)
  keys = to_list(keys)
  local keys_len = #keys

  if keys_len == 0 then
    return nil
  elseif keys_len == 1 then
    return root[keys[1]]
  end

  local function get(parent, ks, limit, i)
    i = i or 1
    limit = limit or #ks
    local k = ks[i]
    local v = parent[k]
    local pos = {parent = parent, key = k, index = i, limit = limit, value = v}

    if i == limit then
      if v == nil then
	return nil, pos
      else
	return v, pos
      end
    elseif v == nil then
      return nil, pos
    elseif type(v) ~= 'table' then 
      return nil, pos
    else
      return get(v, ks, limit, i+1)
    end
  end

  return get(root, keys, #keys, 1)
end

function utils.set(keys, value, force)
  keys = to_list(keys)
  local keys_len = #keys

  if keys_len == 0 then
    return false, nil
  elseif keys_len == 1 then
    local current = root[keys[1]]
    if current == nil or force then
      root[keys[1]] = value
      return true, {
	parent = root, keys = keys,
	key = keys[1],  value = value,
	force = force,
      }
    end
  end

  local function set(parent, ks, limit, i)
    i = i or 1
    limit = limit or #ks
    local k = ks[i]
    local v = parent[k]
    local pos = {parent = parent, key = k, index = i, limit = limit, value = v}

    if i == limit then
      if v == nil or force then
	parent[k] = value
	return true, pos
      else
	return false, pos
      end
    elseif v == nil then
      if force then
        parent[k] = {}
        return set(parent[k], ks, limit, i)
      else
        return false, pos
      end
    elseif type(v) ~= 'table' then 
      return false, pos
    else
      return set(v, ks, limit, i+1)
    end
  end

  return set(root, keys, #keys, 1)
end

function utils.log(msg, object, overrides)
  local date = os.date()
  local context = {message = msg, context = object}

  if overrides then
    context = vim.deepcopy(context)
    for key, value in pairs(overrides) do
      context[key] = value
    end
  end

  root.logs[#root.logs+1] = context
  return context
end

function utils.set_keymap(name, modes, keys, command, opts) 
  name = name or (#root.keymap + 1)
  modes = modes or {"n"}
  local command_type = type(command)
  local keys_type = type(keys)
  local name_type = type(name)
  local modes_type = type(modes)

  assert(
    keys_type == 'string',
    "keys: expected string"
  )

  assert(
    command_type == 'string' or command_type == 'function',
    "command: expected string | function"
  )

  assert(
    name_type == 'string' or name_type == 'number',
    'name: expected string|number'
  )

  assert(
    modes_type == 'string' or modes_type == 'table',
    'name: expected string|table'
  )

  if modes_type == 'string' then
    local _modes = {}
    for i=1, #modes do
      local m = string.sub(modes, i, i)
      _modes[#_modes+1] = m
    end
    modes = _modes
  end

  if type(opts) == 'string' then
    local _opts = opts
    opts = {desc = _opts}
  elseif opts == nil then
    opts = {}
  else
    opts = vim.deepcopy(opts)
  end

  if opts.desc == nil then
    if command_type == 'string' then
      opts.desc = command_type
    else
      opts.desc = string.format('user_config.keymap[%s]', tostring(name))
    end
  end

  local ok, msg = pcall(vim.keymap.set, modes, keys, command, opts)
  local args = {modes, keys, commands, opts, name = name}

  if ok then
    utils.set({'keymap', name}, args)
    return true, nil
  elseif msg ~= nil then
    utils.log(msg, args)
    return false, msg
  end
end

function utils.set_autocmd(name, event, pattern, command, opts)
  name = name or (#root.autocmd + 1)
  opts = opts or {}

  assert_type(name, {'string', 'number'})
  assert_type(event, {'string', 'table'})
  assert_type(pattern, {'string', 'table'})
  assert_type(command, {'string', 'function'})
  assert_type(opts, 'table')

  event = to_list(event)
  pattern = to_list(pattern)
  local use = {pattern = pattern, desc = opts.desc}

  if type(command) == 'function' then
    use.callback = command
  else
    use.command = command
  end

  if use.desc == nil then
    use.desc = tostring(string.format('user_config.autocmd[%s]', tostring(name)))
  end

  local args = { event, use, name = name }
  local ok, msg = pcall(vim.api.nvim_create_autocmd, event, use)

  if ok then
    root.autocmd[name] = args
    return true, nil
  else
    return false, msg
  end
end

utils.set({'a', 'b', 'c'}, 1, true)
dump(user_config)


return user_config
