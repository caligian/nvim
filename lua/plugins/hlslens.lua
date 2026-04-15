return {
  'kevinhwang91/nvim-hlslens',
  config = function ()
    require('hlslens').setup()

    local kopts = {noremap = true, silent = true}
    -- local with_desc = function (desc)
    --   local opts = {}
    --   for key, value in pairs(kopts) do opts[key] = value end
    --   opts.desc = desc
    -- end
    --
    vim.keymap.set(
      'n', 'n',
      [[<Cmd>execute('normal! ' . v:count1 . 'n')<CR><Cmd>lua require('hlslens').start()<CR>]],
      kopts
    )

    vim.keymap.set(
      'n', 'N',
      [[<Cmd>execute('normal! ' . v:count1 . 'N')<CR><Cmd>lua require('hlslens').start()<CR>]],
      kopts
    )

    vim.keymap.set('n', '*', [[*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.keymap.set('n', '#', [[#<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.keymap.set('n', 'g*', [[g*<Cmd>lua require('hlslens').start()<CR>]], kopts)
    vim.keymap.set('n', 'g#', [[g#<Cmd>lua require('hlslens').start()<CR>]], kopts)
  end
}
