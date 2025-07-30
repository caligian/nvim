user_config.filetypes = user_config.filetypes or {}
user_config.terminals = user_config.terminals or {}
user_config.repls = user_config.repls or { repls = {}, shells = {}, shell = false }
user_config.augroups = user_config.augroups or {}
user_config.autocmds = user_config.autocmds or {}
user_config.dir = vim.fn.stdpath('config')
user_config.lua_dir = vim.fn.stdpath('config') .. '/lua'
user_config.config_dir = user_config.lua_dir .. '/config'
user_config.filetypes_dir = user_config.config_dir .. '/filetypes'
user_config.data_dir = vim.fn.stdpath('data')
user_config.workspaces = user_config.workspaces or {}
user_config.shell_command = user_config.shell_command or 'bash'

local str = require('lib.string')
local list = require('lib.list')
local dict = require('lib.dict')
local types = require('lib.type')
local augroup = require('lib.augroup')
local window = require('lib.window')
local buffer = require('lib.buffer')
local tabpage = require('lib.tabpage')
local filetype  = require('lib.filetype')
local repl = require('lib.repl')
local nvim = require('lib.nvim')
local terminal = require('lib.terminal')

user_config.terminal = terminal
user_config.str = str
user_config.list = list
user_config.dict = dict
user_config.types = types
user_config.augroup = augroup
user_config.window = window
user_config.buffer = buffer
user_config.filetype = filetype
user_config.repl = repl
user_config.tabpage = tabpage
user_config.nvim = nvim

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

function user_config:repl_root_dir(bufnr)
  local bufname = buffer.name(bufnr)
  local ft = buffer.filetype(bufnr)
  local repl_opts = dict.get(self.filetypes, {ft, 'repl'})

  if not bufname:match('[a-zA-Z0-9]') or not ft:match('[a-zA-Z0-9]') then
    return false
  elseif not repl_opts then
    return false
  end

  return buffer.workspace(bufnr, {
    pattern = dict.get(repl_opts, {'root', 'pattern'}) or {'.git'},
    check_depth = dict.get(repl_opts, {'root', 'check_depth'}) or 4,
  })
end

function user_config:get_repl(bufnr, shell, running)
  local cwd = self:repl_root_dir(bufnr)
  if not cwd then
    return false
  end

  local exists
  if shell then
    exists = self.repls.shells[cwd]
  else
    local ft = buffer.filetype(bufnr)
    exists = dict.get(self.repls.repls, {cwd, ft})
  end

  if exists then
    if running and not exists:running() then
      return false
    else
      return exists
    end
  end
end

function user_config:create_repl(bufnr, shell)
  local exists = self:get_repl(bufnr, shell, true)
  if exists then
    return exists
  end

  local ws = self:repl_root_dir(bufnr)
  if not ws then
    return false
  end

  local ft = buffer.filetype(bufnr)
  local opts = self.filetypes[ft].repl

  if shell then
    opts = dict.merge(vim.deepcopy(opts), {shell = true})
  else
    opts = dict.merge(vim.deepcopy(opts), {filetype = ft})
  end

  return repl:new(ws, opts)
end

function user_config:on_exit(name, pattern, callback)
  local opts = {pattern = pattern}
  user_config.default_augroup:add_autocmd(name, 'VimLeavePre', callback, opts)
end

function user_config:query(...)
  return user_config.dict.get(user_config, {...})
end

function user_config:setup()
  self:set_filetypes()
  self:load_plugins()
  self:set_opts()
  self:set_autocmds()
  self:set_keymaps()
end

function user_config:start_shell()
  if not user_config.repls.shell then
    user_config.repls.shell = user_config.terminal:new(
      user_config.shell_command,
      os.getenv('HOME')
    )
  end
  local term = user_config.repls.shell
  if not term then
    return false
  else
    term:start()
  end
end

return user_config
