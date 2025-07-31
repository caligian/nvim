local dict = require('lib.dict')

return {
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  {
    'neovim/nvim-lspconfig',
    dependencies = {'saghen/blink.cmp'},
    config = function()
      local fts = {}
      local i = 1

      for _, config in pairs(user_config.filetypes) do
        if config:has_lsp_config() then
          fts[i] = config
          i = i + 1
        end
      end

      local capabilities = require('blink.cmp').get_lsp_capabilities()
      for _, ft in ipairs(fts) do
        local server, config = ft:get_lsp_config()
        config = vim.deepcopy(config)
        config = dict.merge(config, {
          capabilities = vim.deepcopy(capabilities)
        })
        vim.lsp.config(server, config)
        vim.lsp.enable(server)
      end
    end
  },
  {
    "folke/lazydev.nvim",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
      {
        "<leader>l.",
        "<cmd>Trouble diagnostics toggle<cr>",
        desc = "Diagnostics (Trouble)",
      },
      {
        "<leader>ld",
        "<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
        desc = "Buffer Diagnostics (Trouble)",
      },
    },
  }
}

