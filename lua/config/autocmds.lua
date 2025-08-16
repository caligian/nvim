local class = require 'lua-utils.class'
local buffer = user_config.buffer
local augroup = user_config.default_augroup
local add = class.create_instance_method(augroup, 'add_autocmd')

add('FileType',  'qf', function ()
  vim.keymap.set('n', 'q', ':hide<CR>', {
    desc = 'Hide window', buffer = buffer.current()
  })
end)
