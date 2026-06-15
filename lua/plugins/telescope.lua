return {
  'nvim-telescope/telescope.nvim',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-project.nvim',
  },
  config = function()
    require("telescope").setup {
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
  end,
  {
    'nvim-telescope/telescope-project.nvim',
    dependencies = { 'nvim-telescope/telescope.nvim' },
    config = function ()
      require('telescope').load_extension('project')
    end
  },
  {
    "nvim-telescope/telescope-file-browser.nvim",
    dependencies = { 'nvim-telescope/telescope.nvim', "nvim-lua/plenary.nvim" },
    config = function ()
      require("telescope").load_extension("file_browser")
    end
  }
}
