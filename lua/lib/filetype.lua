local types = require('lib.type')
local dict = require('lib.dict')
local augroup = require('lib.augroup')
local buffer = require('lib.buffer')
local validate = require('lib.validate')
local str = require('lib.string')
local nvim = require('lib.nvim')
local class = require('lib.class')
local buffer_group = require 'lib.buffer_group'

--- Valid options
-- {
--   keymaps = {{'n', '<leader>ff', printf}},
--   autocmds = {function() vim.o.something = true end},
--   buffer = {
--     vars = {a = 1, b = 2, c = 3},
--     opts = {c = 2, d = 10}
--   },
--   root = {
--     pattern = {'.git'},
--     check_depth = 4,
--   },
--   lsp = {'jedi_language_server', ...lsp_settings},
--   shell_command = 'bash',
--   repl = {
--     command = 'ipython3', -- dir will be set to root
--     input = {
--       use_file = true,
--       file_string = '%%load %s',
--       apply = function(lines) return lines end
--     },
--   }
-- }

local filetype = class 'filetype'

local function update_lsp_config(opts)
  local server
  server, lsp_opts = dict.get(opts, {'lsp', 1})
  if not server then
    return
  end

  local ok, config = pcall(require, 'nvim-lspconfig.lsp.' .. server)
  if ok then dict.merge(lsp_opts, config) end

  local repl_command = dict.get(opts, {'repl', 'command'})
  if not repl_command then
    return
  end

  if not dict.get(opts, {'root', 'pattern'}) then
    if config.root_markers then
      dict.set(opts, {'root', 'pattern'}, config.root_markers, true)
    else
      dict.set(opts, {'root', 'pattern'}, {'.git'}, true)
    end
  end

  dict.set_unless(opts, {'root', 'check_depth'}, 4)
end

function filetype:initialize(opts)
  if types.string(opts) then
    opts = require('config.filetypes.' .. opts)
  end

  validate.opts(opts, {
    name = types.string,
    opt_keymaps = types.dict,
    opt_autocmds = types.dict,
    opt_buffer = {
      opt_vars = types.dict,
      opt_opts = types.dict
    },
    opt_lsp = types.table,
    opt_repl = {
      command = types.string,
      opt_input = {
        opt_use_file = types.boolean,
        opt_file_string = types.string,
        opt_apply = types.fun
      }
    }
  })

  update_lsp_config(opts)
  dict.merge(self, opts)

  if self.lsp then
    validate.server(opts.lsp[1], 'string')
  end

  self.require_path = 'config.filetypes.' .. self.name
  self.augroup = augroup('user_config.' .. self.name)
  self.loaded = false
  user_config.filetypes[self.name] = self

  self:setup()
end

function filetype:get_lsp_config()
  local config = self.lsp
  if not config then return end

  config = vim.deepcopy(config)
  local server = config[1]
  table.remove(config, 1)

  return server, config
end

function filetype:has_lsp_config()
  return types.table(self.lsp)
end

function filetype:require()
  return require(self.require_path)
end

function filetype:set_autocmds()
  if not self.autocmds then
    return
  end

  for name, callback in pairs(self.autocmds) do
    local opts = {name = name, desc = name}
    self.augroup:add_autocmd('FileType', self.name, callback, opts)
  end

  return true
end

function filetype:set_keymaps()
  if self.keymaps then
    self:add_keymaps(self.keymaps)
    return true
  end
end

function filetype:set_buffer_group()
  if self.buffer_group then
    return self.buffer_group
  else
    self.buffer_group = buffer_group(self.name, function (bufnr)
      return buffer.filetype(bufnr) == self.name
    end)
    self.buffer_group:enable()
    return self.buffer_group
  end
end

function filetype:set_buf_vars()
  self.augroup:add_autocmd('FileType', self.name, function()
    if self.buffer and self.buffer.vars then
      local curbuf = buffer.current()
      for key, value in pairs(self.buffer.vars) do
        buffer.set_var(curbuf, key, value)
      end
    end
  end, {name = 'buffer.variables'})
end

function filetype:set_buf_opts()
  self.augroup:add_autocmd('FileType', self.name, function()
    if self.buffer and self.buffer.opts then
      local curbuf = buffer.current()
      for key, value in pairs(self.buffer.opts) do
        buffer.set_opt(curbuf, key, value)
      end
    end
  end, {name = 'buffer.options'})
end

function filetype:add_autocmd(callback, opts)
  opts = opts or {}
  validate.opts(opts, 'table')
  opts = vim.deepcopy(opts)
  opts.pattern = self.name
  self.augroup:add_autocmd('FileType', self.name, callback, opts)
end

function filetype:add_keymap(name, mode, lhs, rhs, opts)
  opts = opts or {}
  validate.opts(opts, 'table')
  opts = vim.deepcopy(opts)
  opts.name = 'keymap.' .. name
  self:add_autocmd(function ()
    opts.buffer = buffer.current()
    vim.keymap.set(mode, lhs, rhs, opts)
  end, opts)
end

function filetype:add_keymaps(specs)
  for name, spec in pairs(specs) do
    local mode, lhs, rhs, opts = unpack(spec)
    self:add_keymap(name, mode, lhs, rhs, opts)
  end
end

function filetype:delete_autocmd(name_or_id)
  self.augroup:delete_autocmd(name_or_id)
end

filetype.del_autocmd = filetype.delete_autocmd

function filetype:query(...)
  return dict.get(self, {...})
end

function filetype:root_dir(bufnr)
  local bufname = buffer.name(bufnr)
  local ft = buffer.filetype(bufnr)
  local repl_opts = dict.get(self, {'root', 'pattern'})

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

function filetype:setup()
  self:set_buf_vars()
  self:set_buf_opts()
  self:set_autocmds()
  self:set_keymaps()
  self:set_buffer_group()
  self.loaded = true
  return self
end

return filetype
