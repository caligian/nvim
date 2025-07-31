local types = require('lib.type')
local buffer = require('lib.buffer')
local list = require('lib.list')
local dict = require('lib.dict')
local augroup = require('lib.augroup')
local class = require('lib.class')

--- @diagnostic disable: missing-fields

--- Buffer groups
--- Somewhat like project management buffers
local buffer_group = class 'buffer_group'

function buffer_group:initialize(name, pattern)
  self.name = name
  self.group = augroup('buffer_group.' .. name)
  self.pattern = pattern
  self.buffers = {}
  self.length = 0
  self.removed = {}
  self.cache = {buffers = {}, removed = {}}

  user_config.buffer_groups[name] = self
end

function buffer_group:enable()
  if self.enabled then
    return true
  end

  self.group:add_autocmd('BufReadPost', '*', function ()
    self:add(buffer.current())
  end, {name = 'enable'})

  self.enabled = true
end

function buffer_group:disable()
  if self.enabled then
    self.enabled = false
    self.group:delete()
    self.group = false
  end
end

function buffer_group:add(bufnr)
  local bufname = buffer.name(bufnr)
  if not buffer.exists(bufnr) then
    return false
  elseif self.cache.removed[bufnr] or self.cache.removed[bufname] then
    return false
  elseif bufname:match(self.pattern) then
    self.length = self.length + 1
    self.buffers[self.length] = {bufnr, bufname}
    self.cache.buffers[bufnr] = self.buffers[self.length]
    self.cache.buffers[bufname] = self.buffers[self.length]
    return true
  end
end

function buffer_group:has(bufnr, removed)
  local xs = ifnil(removed, self.cache.buffers, self.cache.removed)
  return xs[bufnr] ~= nil
end

function buffer_group:index(bufnr, removed)
  if not buffer.exists(bufnr) then
    return false
  end

  local search_in = ifelse(removed, self.removed, self.buffers)
  local is_num = types.number(bufnr)
  local is_str = types.string(bufnr)

  for i=1, #search_in do
    local buf, bufname = unpack(search_in[i])
    if is_num and bufnr == buf then
      return i
    elseif is_str and bufnr == bufname then
      return i
    end
  end

  return false
end

function buffer_group:remove(bufnr)
  local ind = self:index(bufnr)
  if not ind then
    return false
  else
    local x = self.buffers[ind]
    self.removed[#self.removed+1] = x
    self.cache.removed[x[1]] = x
    self.cache.removed[x[2]] = x
    self.cache.buffers[x[1]] = false
    self.cache.buffers[x[2]] = false
    table.remove(self.buffers, ind)
    return true
  end
end

function buffer_group:restore(bufnr)
  local x = self.cache.removed[bufnr]
  if not x then
    return false
  else
    local ind = self:index(bufnr, true)
    table.remove(self.removed, ind)
    self.buffers[self.length+1] = x
    self.cache.removed[x[1]] = false
    self.cache.removed[x[2]] = false
    self.cache.buffers[x[1]] = x
    self.cache.buffers[x[2]] = x
    self.length = self.length + 1
    return true
  end
end

function buffer_group:create_picker()
end

return buffer_group
