local nvim = user_config.nvim

vim.cmd "noremap fs :w!<CR>"
vim.cmd "noremap fp :e ~/.config/nvim/lua/<CR>"
vim.cmd "noremap fv :w! <bar> source %<CR>"
vim.cmd 'noremap <A-space> :noh<CR>'
vim.cmd 'noremap bp <cmd>bprev<CR>'
vim.cmd 'noremap bn <cmd>bnext<CR>'
vim.cmd 'noremap <space>w <C-w>'

vim.keymap.set('v', '<leader>ee', function()
end)


