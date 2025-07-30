return {
  'nvim-telescope/telescope.nvim', tag = '0.1.8',
  dependencies = { 'nvim-lua/plenary.nvim' },
  config = function()
    vim.cmd([[
    nnoremap <space>ff <cmd>Telescope find_files<cr>
    nnoremap <space>fg <cmd>Telescope git_files<cr>
    nnoremap <space>? <cmd>Telescope live_grep<cr>
    nnoremap <space>/ <cmd>Telescope grep_string<cr>
    nnoremap <space>bb <cmd>Telescope buffers<cr>
    nnoremap <space>fr <cmd>Telescope oldfiles<CR>
    nnoremap <space>l/ <cmd>Telescope lsp_document_symbols<CR>
    nnoremap <space>ls <cmd>Telescope treesitter<CR>
    nnoremap <space>l? <cmd>Telescope lsp_workspace_symbols<CR>
    nnoremap <space>ld <cmd>Telescope diagnostics<CR>
    nnoremap <space>' <cmd>Telescope registers<CR>
    nnoremap <space><space> <cmd>Telescope resume<CR>
    ]])
  end
}
