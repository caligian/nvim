local class = require('lib.class')
local types = require('lib.type')
local dict = require('lib.dict')
local terminal = require('lib.terminal')
local repl = class('repl', terminal)

-- opts = {
--   command = types.string,
--   root = {
--     pattern = types.list_of(types.string),
--     check_depth = types.number
--   },
--   input = {
--     use_file = types.boolean,
--     file_string = types.string,
--     apply = types.fun
--   }
-- }
--
function repl:initialize(cwd, opts)
  self.root_pattern = dict.get(opts, {'root', 'pattern'})
  self.root_check_depth = dict.get(opts, {'root', 'check_depth'})
  self.input_use_file = dict.get(opts, {'input', 'use_file'})
  self.input_file_string = dict.get(opts, {'input', 'file_string'})
  self.input_apply = dict.get(opts, {'input', 'apply'})
  self.filetype = opts.filetype or opts.ft
  self.ft = self.filetype
  self.shell = opts.shell

  terminal.initialize(self, opts.command or opts.cmd, cwd)

  if self.shell then
    self.cmd = config.shell_command or 'bash'
    self.command = self.cmd
    config.repls.shells[cwd] = self
  else
    types.validate.filetype(opts.filetype, types.string)
    config.repls.repls[cwd] = config.repls.repls[cwd] or {}
    config.repls.repls[cwd][self.filetype] = self
  end
end

function repl:exists(callback)
  local exists
  if self.shell then
    exists = config.repls.shells[self.cwd]
  else
    exists = dict.get(
      config.repls.repls,
      {self.cwd, self.filetype}
    )
  end

  if exists then
    return ifelse(callback, callback(exists), exists)
  else
    return false
  end
end

function repl:send(s)
  if self.input_use_file then
    local filename = vim.fn.tempname()
    local fh = io.open(filename, 'w')

    fh:write(s)
    fh:close()

    types.validate.file_string(self.input_file_string, 'string')
    s = self.input_file_string:format(filename)

    local timer = vim.uv.new_timer()
    timer:start(10000, 0, vim.schedule_wrap(function ()
      pcall(vim.fs.rm, filename)
      timer:stop()
      timer:close()
    end))
  end

  return terminal.send(self, s)
end

return repl
