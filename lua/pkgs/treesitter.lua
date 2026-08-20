return {
  {
    'mfussenegger/nvim-treehopper',
    config = function()
      vim.cmd [[
      omap     <silent> m :<C-U>lua require('tsht').nodes()<CR>
      xnoremap <silent> m :lua require('tsht').nodes()<CR>
      ]]
    end
  },
  {
    "kiyoon/treesitter-indent-object.nvim",
    keys = {
      {
        "ai",
        function() require 'treesitter_indent_object.textobj'.select_indent_outer() end,
        mode = { "x", "o" },
        desc = "Select context-aware indent (outer)",
      },
      {
        "aI",
        function()
          require 'treesitter_indent_object.textobj'.select_indent_outer(true, 'V')
          require 'treesitter_indent_object.refiner'.include_surrounding_empty_lines()
        end,
        mode = { "x", "o" },
        desc = "Select context-aware indent (outer, line-wise)",
      },
      {
        "ii",
        function() require 'treesitter_indent_object.textobj'.select_indent_inner() end,
        mode = { "x", "o" },
        desc = "Select context-aware indent (inner, partial range)",
      },
      {
        "iI",
        function() require 'treesitter_indent_object.textobj'.select_indent_inner(true, 'V') end,
        mode = { "x", "o" },
        desc = "Select context-aware indent (inner, entire range) in line-wise visual mode",
      },
    },
    lazy = false,
  },
  {
    'RRethy/nvim-treesitter-textsubjects',
    config = function()
      require('nvim-treesitter-textsubjects').configure({
        prev_selection = ',',
        keymaps = {
          ['.'] = 'textsubjects-smart',
          [';'] = 'textsubjects-container-outer',
          ['i;'] = 'textsubjects-container-inner',
        },
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    branch = 'master',
    lazy = false,
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup {
        sync_install = false,
        auto_install = false,
        ignore_install = { 'tex', 'nix', 'bash', 'r', 'lua', 'python', 'erlang', 'elixir', 'perl' },
        highlight = {
          enable = true,
          disable = {}
        },
        indent = {
          enable = true,
          disable = { 'python' },
        }
      }
    end

  },
  {
    'nvim-treesitter/nvim-treesitter-textobjects',
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function ()
      require("nvim-treesitter-textobjects").setup {
        move = {
          enable = true,
          set_jumps = true,
        },
        select = {
          enable = true,
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
            ['@block.outer'] = '<c-v>',
          },
          include_surrounding_whitespace = true,
        },
      }

      vim.keymap.set({ "n", "x", "o" }, "]m", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@function.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]c", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@class.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]o", function()
        require("nvim-treesitter-textobjects.move").goto_next_start({"@loop.inner", "@loop.outer"}, "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]s", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@local.scope", "locals")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]z", function()
        require("nvim-treesitter-textobjects.move").goto_next_start("@fold", "folds")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]M", function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@function.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]C", function()
        require("nvim-treesitter-textobjects.move").goto_next_end("@class.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "[m", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "[c", function()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@class.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "[M", function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@function.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "[C", function()
        require("nvim-treesitter-textobjects.move").goto_previous_end("@class.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "]d", function()
        require("nvim-treesitter-textobjects.move").goto_next("@conditional.outer", "textobjects")
      end)

      vim.keymap.set({ "n", "x", "o" }, "[d", function()
        require("nvim-treesitter-textobjects.move").goto_previous("@conditional.outer", "textobjects")
      end)

      local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"
      vim.keymap.set({ "n", "x", "o" }, ";", ts_repeat_move.repeat_last_move_next)
      vim.keymap.set({ "n", "x", "o" }, ",", ts_repeat_move.repeat_last_move_previous)
      vim.keymap.set({ "n", "x", "o" }, "f", ts_repeat_move.builtin_f_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "F", ts_repeat_move.builtin_F_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "t", ts_repeat_move.builtin_t_expr, { expr = true })
      vim.keymap.set({ "n", "x", "o" }, "T", ts_repeat_move.builtin_T_expr, { expr = true })
    end
  },
}
