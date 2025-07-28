local types = require('lib.type')
local list = require('lib.list')
local dict = require('lib.dict')

local augroup = types.new('augroup')
user_config.augroup = augroup

--- Autocmds
augroup.autocmd = types.new('autocmd')
user_config.autocmd = augroup.autocmd
local autocmd = augroup.autocmd

function autocmd:initialize(group, name, event, callback, opts)
  self.augroup = group
  self.name = name
  self.event = event

  if types.string(callback) then
    self.command = callback
  else
    self.callback = callback
  end

  self.id = nil
  dict.merge(self, opts or {})
end

function autocmd:enable()
  if self.id then
    return self.id
  end

  self.id = vim.api.nvim_create_autocmd(self.event, {
    group = self.augroup,
    pattern = self.pattern,
    buffer = self.buffer,
    desc = self.desc,
    callback = self.callback,
    command = self.command,
    once = self.once,
    nested = self.nested
  })

  user_config.autocmds[self.id] = self
  user_config.autocmds[self.name] = self

  return self.id
end

function autocmd:delete()
  if self.id then
    vim.api.nvim_del_autocmd(self.id)
    user_config.autocmds[self.id] = nil
    user_config.autocmds[self.name] = nil
    return true
  end
end

autocmd.del = autocmd.delete

--- Augroups
function augroup:initialize(name)
  self.name = name
  self.autocmds = {}
end

function augroup:enable()
  if self.id then return self.id end
  self.id = vim.api.nvim_create_augroup(self.name, {clear = true})
  user_config.augroups[self.name] = self
  user_config.augroups[self.id] = self
  return self.id
end

function augroup:delete()
  if self.id then
    vim.api.nvim_del_augroup_by_id(self.id)
    user_config.augroups[self.name] = nil
    user_config.augroups[self.id] = nil
    self.id = nil
    for _, au in pairs(self.autocmds) do au:delete() end
    self.autocmds = {}
    return true
  end
end

augroup.del = augroup.delete

function augroup:delete_autocmd(name_or_id)
  local au = self.autocmds[name_or_id]
  if au == nil then
    return
  else
    au:delete()
    self.autocmds[au.name] = nil
    return true
  end
end

augroup.del_autocmd = augroup.delete_autocmd

function augroup:get_autocmds_with_id()
  return list.filter(
    dict.values(self.autocmds),
    function(_, value) return value.id ~= nil end
  )
end

function augroup:add_autocmd(name, event, callback, opts)
  name = self.name .. '.' .. name
  self.autocmds[name] = autocmd:new(self.id, name, event, callback, opts)
  self.autocmds[name]:enable()
  return self.autocmds[name]
end

function augroup:add_autocmds(specs)
  for name, spec in pairs(specs) do
    local event, callback, opts = unpack(spec)
    self:add_autocmd(name, event, callback, opts)
  end
end

user_config.default_augroup = augroup:new('user_defaults')
user_config.default_augroup:enable()

return augroup
