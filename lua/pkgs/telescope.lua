return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-project.nvim',
    "nvim-telescope/telescope-file-browser.nvim",
  },
  config = function()
    local dict = require 'lua-utils.dict'
    local defaults = {}

    dict.merge(defaults, user_config.telescope.theme)
    dict.merge(defaults, user_config.telescope.opts)

    local opts = {
      defaults = defaults,
      pickers = {
        buffers = {
          show_all_buffers = true,
          sort_lastused = true,
          previewer = false,
          mappings = {
            i = {
              ["<c-d>"] = "delete_buffer",
            },
            n = {
              ["dd"] = "delete_buffer",
            }

          }
        }
      }
    }
    -- require('nvim-utils.telescope').setup()
    require("telescope").setup(opts)
    require('telescope').load_extension('project')
    require("telescope").load_extension("file_browser")
  end,
}
