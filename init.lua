require 'lua-utils'
require 'nvim-utils'

user_config:setup()

if vim.g.neovide then
  vim.cmd [[ set guifont=LiterationMono\ Nerd\ Font:h13 ]]
  vim.g.neovide_detach_on_quit = 'always_quit'
  vim.g.neovide_cursor_antialiasing = true
end
