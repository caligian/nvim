return {
  {
    "ellisonleao/gruvbox.nvim",
    config = function ()
      -- require("gruvbox").setup({
      --   terminal_colors = true,
      --   undercurl = true,
      --   underline = true,
      --   bold = true,
      --   italic = { strings = true, emphasis = true, comments = true, operators = false, folds = true, },
      --   strikethrough = true,
      --   invert_selection = false,
      --   invert_signs = false,
      --   invert_tabline = false,
      --   inverse = true,
      --   contrast = "soft",
      --   palette_overrides = {},
      --   overrides = {},
      --   dim_inactive = false,
      --   transparent_mode = false,
      -- })
      -- vim.o.background = 'dark'
      -- vim.cmd [[ color gruvbox ]]
    end
  },
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    ---@class solarized.config
    opts = {},
    config = function(_, opts)
      vim.o.termguicolors = true
      -- require('solarized').setup(opts)
      -- vim.cmd.colorscheme 'solarized'
      -- vim.cmd('hi LineNr guibg=#002b36 guifg=#5f5f5f')
      -- vim.cmd('hi SignColumn guibg=#002b36')
    end,
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      -- vim.o.background = 'light'
      -- vim.cmd("colorscheme rose-pine")
    end
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function ()
      -- vim.o.background = 'dark'
      -- vim.o.cursorline = true
    end
  },
  {
    'barrientosvctor/abyss.nvim',
    dependencies = {'nvim-lualine/lualine.nvim'},
    config = function ()
      -- vim.cmd 'color abyss'
    end
  },
  {
    'marko-cerovac/material.nvim',
    dependencies = {'nvim-lualine/lualine.nvim'},
    config = function()
      -- vim.g.material_theme = 'oceanic'
      -- vim.cmd 'color material-oceanic'
    end
  },
  {
    'iagorrr/noctishc.nvim',
    config = function () end
  },
  {
    'projekt0n/github-nvim-theme',
    config = function()
      -- vim.cmd('set bg=light')
      -- vim.cmd('color github_light')
    end,
  }
}
