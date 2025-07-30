local types = require('lib.type')
local dict = require('lib.dict')
local augroup = require('lib.augroup')
local buffer = require('lib.buffer')
local validate = types.validate
local str = require('lib.string')
local nvim = require('lib.nvim')

--- Valid options
-- {
--   keymaps = {{'n', '<leader>ff', printf}},
--   autocmds = {function() vim.o.something = true end},
--   buffer = {
--     vars = {a = 1, b = 2, c = 3},
--     opts = {c = 2, d = 10}
--   },
--   lsp = {'jedi_language_server', ...lsp_settings},
--   shell_command = 'bash',
--   repl = {
--     command = 'ipython3', -- dir will be set to root
--     root = {
--       pattern = {'.git'},
--       check_depth = 4,
--       home = false,
--     },
--     input = {
--       use_file = true,
--       file_string = '%%load %s',
--       apply = function(lines) return lines end
--     },
--   }
-- }

local filetype = types.new('filetype')

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

  dict.set_unless(opts, {'repl', 'root'}, {})
  if not opts.repl.root.pattern then
    if config.root_markers then
      opts.repl.root.pattern = config.root_markers
    else
      opts.repl.root.pattern = {'.git'}
    end
    opts.repl.root.check_depth = opts.repl.root.check_depth or 4
  end
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
      opt_root = {
        opt_pattern = types.list_of('string'),
        opt_check_depth = types.number
      },
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
    types.validate.server(opts.lsp[1], 'string')
  end

  self.require_path = 'config.filetypes.' .. self.name
  self.augroup = augroup:new('user_defaults.' .. str.title(self.name))
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
  if self.autocmds then
    self.augroup:add_autocmds(self.autocmds)
    return true
  end
end

function filetype:set_keymaps()
  if self.keymaps then
    self:add_keymaps(self.keymaps)
    return true
  end
end

function filetype:set_buf_vars()
  if self.buffer and self.buffer.vars then
    self.augroup:add_autocmd('buffer_variables', 'FileType', function()
      local curbuf = buffer.current()
      for key, value in pairs(self.buffer.vars) do
        buffer.set_var(curbuf, key, value)
      end
    end, {pattern = self.name})
  end
end

function filetype:set_buf_opts()
  if self.buffer and self.buffer.opts then
    self.augroup:add_autocmd('buffer_options', 'FileType', function()
      local curbuf = buffer.current()
      for key, value in pairs(self.buffer.opts) do
        buffer.set_opt(curbuf, key, value)
      end
    end, {pattern = self.name})
  end
end

function filetype:add_autocmd(name, callback, opts)
  opts = opts or {}
  types.validate.opts(opts, 'table')
  self.augroup:add_autocmd(name, 'FileType', callback, {
    pattern = self.name,
    desc = opts.desc,
    once = opts.once,
    nested = opts.nested
  })
end

function filetype:add_keymap(name, mode, lhs, rhs, opts)
  opts = opts or {}
  types.validate.opts(opts, 'table')
  opts = vim.deepcopy(opts)
  name = 'keymap.' .. name
  self:add_autocmd(name, function ()
    opts.buffer = buffer.current()
    vim.keymap.set(mode, lhs, rhs, opts)
  end)
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

function filetype:setup()
  self:set_autocmds()
  self:set_keymaps()
  self:set_buf_vars()
  self:set_buf_opts()
  self.loaded = true
  return self
end

return filetype
