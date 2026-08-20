return {
  {
    "nvimdev/indentmini.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("indentmini").setup()
      vim.api.nvim_create_autocmd('Colorscheme', {
        callback = function()
          vim.cmd.highlight('IndentLine guifg=#48494b')
          vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
        end
      })
    end
  },
}
