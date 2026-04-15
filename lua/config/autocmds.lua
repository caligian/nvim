local class = require 'lua-utils.class'
local buffer = user_config.buffer
local recent_buffers = user_config.buffers.recent
local autocmd = require 'nvim-utils.autocmd'
local path = require 'lua-utils.path_utils'
local add_autocmd = vim.api.nvim_create_autocmd

autocmd('FileType', 'qf', function()
  vim.keymap.set('n', 'q', ':hide<CR>', {
    desc = 'Hide window', buffer = buffer.current()
  })
end)

autocmd("BufWinLeave", '*.*', function()
  vim.cmd.mkview()
end)

autocmd("BufWinEnter", '*.*', function()
  vim.cmd.loadview({ mods = { emsg_silent = true } })
end)

autocmd('BufEnter', '*.*', function(args)
  local bufname = args.match
  recent_buffers.current = bufname
  if recent_buffers[bufname] then
    return
  else
    recent_buffers[bufname] = true
    recent_buffers[#recent_buffers + 1] = bufname
  end
end)
