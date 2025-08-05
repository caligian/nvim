return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function ()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline", 'python', 'r' },
        sync_install = false,
        auto_install = true,
        ignore_install = { "javascript" },
        highlight = {
          enable = true,
        },
        indent = {
          enable = true,
        }
      }
    end

  },
  {
    'RRethy/nvim-treesitter-textsubjects',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function ()
      require('nvim-treesitter-textsubjects').configure({
        prev_selection = ',',
        keymaps = {
          ['.'] = 'textsubjects-smart',
          [';'] = 'textsubjects-container-outer',
          ['i;'] = 'textsubjects-container-inner',
        },
      })
    end
  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function ()
      require('nvim-treesitter.configs').setup {
        textobjects = {
          move = {
            enable = true,
            set_jumps = true,
            goto_next_start = {
              ["]="] = "@assignment.lhs",
              ["]m"] = "@function.outer",
              ["<A-f>"] = "@assignment.lhs",
              ["<A-n>"] = "@function.outer",
              ["]]"] = { query = "@block.outer", desc = "Next block's start" },
              ["]o"] = "@loop.*",
              ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
              ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
            },
            goto_next_end = {
              ["]M"] = "@function.outer",
              ["]["] = "@block.outer",
            },
            goto_previous_start = {
              ["[="] = "@assignment.lhs",
              ["<A-b>"] = "@assignment.lhs",
              ["[m"] = "@function.outer",
              ["<A-p>"] = "@function.outer",
              ["[["] = "@block.outer",
            },
            goto_previous_end = {
              ["[M"] = "@function.outer",
              ["[]"] = "@block.outer",
            },
            goto_next = {
              ["]d"] = "@conditional.outer",
            },
            goto_previous = {
              ["[d"] = "@conditional.outer",
            }
          },
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@class.outer",
              ["ic"] = { query = "@block.inner", desc = "Select inner part of a block region" },
              ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
            },
            selection_modes = {
              ['@parameter.outer'] = 'v',
              ['@function.outer'] = 'V',
              ['@block.outer'] = '<c-v>',
            },
            include_surrounding_whitespace = true,
          },
        },
      }
    end
  }
}
