return {
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  -- {
  --   'stevearc/aerial.nvim',
  --   config = function()
  --     require("aerial").setup({
  --       on_attach = function(bufnr)
  --         vim.keymap.set("n", "g{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
  --         vim.keymap.set("n", "g}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  --       end,
  --     })
  --     vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")
  --   end
  -- },
  {
    'neovim/nvim-lspconfig',
    dependencies = { 'saghen/blink.cmp' },
    config = function()
      local dict = require 'lua-utils.dict'
      local list = require 'lua-utils.list'
      local fts = dict.keys(user_config.filetype)
      local capabilities = require('blink.cmp').get_lsp_capabilities()

      list.each(fts, function (ft)
        local self = user_config.filetype[ft]
        if not self.lsp then
          return
        end

        for server, spec in pairs(self.lsp) do
          local config = vim.deepcopy(spec)
          config = dict.mergef(spec, {
            capabilities = vim.deepcopy(capabilities)
          })
          local ok, msg = pcall(vim.lsp.config, server, config)
          if not ok then
            printf('[ERROR] %s.lsp: %s\nconfig: %s', self.name, msg, config)
          else
            vim.lsp.enable(server)
          end
        end
      end)
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

  --- Need to be setup
  {
    "folke/trouble.nvim",
    opts = {},
  }
}
