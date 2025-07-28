user_config = {}
user_config.augroups = {}
user_config.autocmds = {}
user_config.dir = vim.fn.stdpath('config')
user_config.lua_dir = vim.fn.stdpath('config') .. '/lua'
user_config.config_dir = user_config.lua_dir .. '/config'
user_config.filetypes_dir = user_config.config_dir .. '/filetypes'
user_config.data_dir = vim.fn.stdpath('data')

require('lib.string')
require('lib.list')
require('lib.dict')
require('lib.type')
require('lib.augroup')
require('lib.window')
require('lib.buffer')
require('lib.tabpage')
require('lib.filetype')
require('lib.repl')
require('lib.nvim')

local list = user_config.list
local dict = user_config.dict

function user_config:path(...)
  local args = {...}
  table.insert(args, 1, user_config.dir)
  return table.concat(args, "/")
end

function user_config:lua_path(...)
  local args = {...}
  table.insert(args, 1, user_config.lua_dir)
  return table.concat(args, "/")
end

function user_config:filetype_path(ft)
  return self:lua_path('config/filetypes', ft .. '.lua')
end

function user_config:config_path(modname)
  return self:lua_path('config', modname .. '.lua')
end

function user_config:set_filetypes()
  for f in vim.fs.dir(user_config.filetypes_dir) do
    if f:match('[.]lua$') then
      local ft = f:gsub('[.]lua$', '')
      local req = 'config.filetypes.' .. ft
      local ok, msg = pcall(require, req)
      if ok then user_config.filetype:new(msg) end
    end
  end
end

function user_config:load_plugins()
  require('config.lazy')
end

function user_config:set_opts()
  require('config.options')
end

function user_config:set_keymaps()
  require('config.keymaps')
end

function user_config:set_autocmds()
   require('config.autocmds')
end

return user_config
