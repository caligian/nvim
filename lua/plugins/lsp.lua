local dict = require('lib.dict')
local types = require('lib.type')

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
        vim.lsp.config(server, config)
        require('lspconfig')[server].setup {
          capabilities = vim.deepcopy(capabilities)
        }
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
  }
}

