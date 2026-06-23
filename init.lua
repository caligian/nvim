local config_dir = vim.fn.stdpath('config')
local base_vim = config_dir .. '/base.vim'
vim.cmd(string.format(':source %s', base_vim))

require('nvim-utils.setup')

vim.cmd.highlight('IndentLine guifg=#48494b')
vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
vim.cmd.color('material')
