return {
  {
    "hedyhli/outline.nvim",
    lazy = false,
    config = function()
      require("outline").setup {
        symbols = {
          icon_fetcher = function(kind, _, _)
            return string.format('[%s]', kind)
          end,
        }
      }
      vim.keymap.set(
        "n",
        "<C-t>",
        "<cmd>Outline<CR>",
        { desc = "Toggle Outline" }
      )
    end,
  },
  {
    'mason-org/mason.nvim',
    opts = {}
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    lazy = false,
    config = function()
      require('neo-tree').setup({
        sources = {
          "filesystem",
          "buffers",
          "git_status",
          "document_symbols",
        },
        document_symbols = {
          follow_cursor = true,
          auto_close = false,
        }
      })

      vim.keymap.set('n', '<C-t>', ':Neotree document_symbols<CR>', { desc = 'Neotree doc symbols' })
      vim.keymap.set('n', '<C-p>', ':Neotree<CR>', { desc = 'Neotree' })
    end,
  },
  {
    "Crysthamus/nvim-file-operations",
    dependencies = {
      "nvim-neo-tree/neo-tree.nvim",
    },
    config = function()
      require("nvim-file-operations").setup()
    end,
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

      list.each(fts, function(ft)
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
  {
    "folke/trouble.nvim",
    opts = {},
  }
}
