vim.cmd(":source " .. vim.fn.stdpath('config') .. '/base.vim')

require('nvim-utils.state_utils').setup()

vim.cmd.color('solarized')

autocmd.set('Colorscheme', function ()
  vim.cmd.highlight('IndentLine guifg=#48494b')
  vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
end, {pattern = '*'})
