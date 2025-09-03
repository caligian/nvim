local class = require 'lua-utils.class'
local buffer = user_config.buffer
local recent_buffers = user_config.buffers.recent
local augroup = user_config.default_augroup
local add = class.create_instance_method(augroup, 'add_autocmd')

add('FileType',  'qf', function ()
  vim.keymap.set('n', 'q', ':hide<CR>', {
    desc = 'Hide window', buffer = buffer.current()
  })
end)

add("BufWinLeave", '*.*', function()
  vim.cmd.mkview()
end)

add("BufWinEnter", '*.*', function()
  vim.cmd.loadview({ mods = { emsg_silent = true } })
end)

add('BufEnter', '*.*', function (args)
  local bufname = args.match
  recent_buffers.current = bufname
  if recent_buffers[bufname] then
    return
  else
    recent_buffers[bufname] = true
    recent_buffers[#recent_buffers+1] = bufname
  end
end)
