require 'lua-utils'
require 'nvim-utils'

user_config:set_filetypes()
user_config:load_plugins()
user_config:set_opts()
user_config:set_autocmds()
user_config:set_keymaps()
user_config:set_buffer_groups()

vim.cmd('set bg=dark')
vim.cmd('color github_dark')

if vim.g.neovide then
  vim.cmd("set guifont=Inconsolata\\ Nerd\\ Font\\ Propo:h12")
end
