local dict = require('lib.dict')

return {
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  {
    'stevearc/aerial.nvim',
    config = function ()
      require("aerial").setup({
        on_attach = function(bufnr)
          vim.keymap.set("n", "g{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
          vim.keymap.set("n", "g}", "<cmd>AerialNext<CR>", { buffer = bufnr })
        end,
      })
      vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
    end
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
  }
}

