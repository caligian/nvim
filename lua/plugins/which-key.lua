return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  opts = {},
  config = function ()
    require('which-key').add {
      {'<leader>f', group = 'File'},
      {'<leader>b', group = 'Buffer'},
      {'<leader>w', group = 'Window'},
      {'<leader>g', group = 'Git'},
      {'<leader>l', group = 'LSP'},
      {'<leader>p', group = 'Project'},
      {'<leader>e', group = 'Lua eval'},
      {'<leader>r', group = 'Project REPL'},
      {'<leader>x', group = 'Shell'},
      {'<leader><enter>', group = 'Project shell'},
      {'<leader>q', group = 'Quit vim'}
    }
  end
}
