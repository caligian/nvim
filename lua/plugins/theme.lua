return {
  {
    "ellisonleao/gruvbox.nvim",
    config = function ()
      require("gruvbox").setup({
        terminal_colors = true,
        undercurl = true,
        underline = true,
        bold = true,
        italic = { strings = true, emphasis = true, comments = true, operators = false, folds = true, },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        inverse = true,
        contrast = "soft",
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.o.background = 'dark'
    end
  },
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    ---@class solarized.config
    opts = {},
    config = function(_, opts)
      vim.o.termguicolors = true
      vim.o.background = 'light'
      --- require('solarized').setup(opts)
      --- vim.cmd.colorscheme 'solarized'
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      vim.o.background = 'light'
      vim.cmd("colorscheme rose-pine")
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function ()
      vim.o.background = 'dark'
      vim.o.cursorline = true
      vim.cmd 'colorscheme catppuccin-mocha'
    end
  }
}
