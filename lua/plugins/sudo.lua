return {
  'lambdalisue/vim-suda',
  config = function ()
    vim.cmd "let g:suda#prompt = '(sudo)# '"
    vim.g.suda_smart_edit = 1
  end
}
