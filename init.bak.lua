local defkey = vim.keymap.set
local autocmd = vim.api.nvim_create_autocmd
local cmd = vim.cmd
local data_path = vim.fn.stdpath('data')
local config_path = vim.fn.stdpath('config')
local lazy_path = data_path .. '/lazy/lazy.nvim'

--- Basic options
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.autoindent = true
vim.o.smartindent = true
vim.o.cursorline = true
vim.o.number = true
vim.o.relativenumber = true

--- Colorscheme
cmd 'color unokai'

--- Keybindings
defkey('n', '<space>fs', ':w!<CR>', {desc = 'Save file'})
defkey('n', '<space>fv', ':w! <bar> luafile %<CR>', {desc = 'Save file & source config'})
defkey('n', '<space>w', '<C-w>', {desc = 'Window operations'})
defkey('n', '<C-g>', ':noh<CR>', {desc = ':noh<CR>'})

--- Autocmds
autocmd({'FileType'}, {
    pattern = {'lua', 'nix'},
    callback = function() 
        vim.o.tabstop = 2
        vim.o.shiftwidth = 2
        vim.o.softtabstop = 2
    end
})

--- Plugins setup
if not vim.loop.fs_stat(lazy_path) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazy_path,
  })
end

vim.opt.rtp:prepend(lazy_path)

-- Plugins configuration
require("lazy").setup({
  { 'windwp/nvim-autopairs', config = true },
  { "kylechui/nvim-surround", version = "^4.0.0"},
}) 

