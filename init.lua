vim.cmd(":source " .. vim.fn.stdpath('config') .. '/base.vim')

local state_utils = require 'nvim-utils.state_utils'
state_utils.setup()

vim.cmd.color('material-oceanic')
vim.cmd.highlight('IndentLine guifg=#48494b')
vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
