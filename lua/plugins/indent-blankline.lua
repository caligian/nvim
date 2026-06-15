return {
  {
    "nvimdev/indentmini.nvim",
    config = function()
      require("indentmini").setup()
      vim.cmd.highlight('IndentLine guifg=#48494b')
      vim.cmd.highlight('IndentLineCurrent guifg=#777b7e')
    end
  },
}
