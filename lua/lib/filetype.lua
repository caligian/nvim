local types = require('lib.type')
local dict = require('lib.dict')
local augroup = require('lib.augroup')
local buffer = require('lib.buffer')
local validate = types.validate
local str = require('lib.string')

--- Valid options
-- {
--   keymaps = {{'n', '<leader>ff', printf}},
--   autocmds = {function() vim.o.something = true end},
--   buffer = {
--     vars = {a = 1, b = 2, c = 3},
--     opts = {c = 2, d = 10}
--   },
--   lsp = {server = 'jedi_language_server', config = {}},
--   shell_command = 'bash',
--   repl = {
--     command = 'ipython3', -- dir will be set to root
--     root = {
--       pattern = {'.git'},
--       check_depth = 4,
--     },
--     input = {
--       use_file = true,
--       file_string = '%%load %s',
--       apply = function(lines) return lines end
--     },
--   }
-- }

local filetype = types.new('filetype')
user_config.filetypes = user_config.filetypes or {}
user_config.filetype = filetype

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
    opt_lsp = {
      opt_server = types.string,
      opt_config = types.dict
    },
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

  dict.merge(self, opts)
  dict.set_unless(self, {'repl', 'root', 'pattern'}, {'.git'})
  dict.set_unless(self, {'repl', 'root', 'check_depth'}, 4)

  self.require_path = 'config.filetypes.' .. self.name
  self.augroup = augroup:new('UserFiletype' .. str.title(self.name))
  self.loaded = false

  user_config.filetypes[self.name] = self

  self:setup()
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

function filetype:setup()
  self:set_autocmds()
  self:set_keymaps()
  self:set_buf_vars()
  self:set_buf_opts()
  self.loaded = true
  return self
end
