return {
  { "miikanissi/modus-themes.nvim", priority = 1000, lazy = false },
  {
    "ellisonleao/gruvbox.nvim",
    opts = {
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
    },
    lazy = false,
    priority = -1,
  },
  {
    'maxmx03/solarized.nvim',
    lazy = false,
    ---@class solarized.config
    opts = {},
  },
  {
    "rose-pine/neovim",
    name = "rose-pine",
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
  },
  {
    'barrientosvctor/abyss.nvim',
    dependencies = { 'nvim-lualine/lualine.nvim' },
  },
  {
    'marko-cerovac/material.nvim',
    dependencies = { 'nvim-lualine/lualine.nvim' },
    lazy = false
  },
  {
    'iagorrr/noctishc.nvim',
    lazy = false,
  },
  {
    'projekt0n/github-nvim-theme',
    lazy = false,
  },
  {
    "zaldih/themery.nvim",
    lazy = false,
    config = function()
      require("themery").setup({
        --- TODO
        themes = { "abyss", "catppuccin", "material-darker", "material-deep-ocean", "material-oceanic" },
        livePreview = true,
      })
      vim.keymap.set('n', "<leader>hc", ":Themery<CR>", { desc = "Set theme" })
    end
  },
  {
    "bjarneo/pixel.nvim",
    priority = 1000,
  },
  {
    "dasupradyumna/midnight.nvim",
    lazy = false,
    priority = 1000,
  }
}
