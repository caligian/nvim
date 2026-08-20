return {
  { "folke/snacks.nvim", opts = {} },
  {
    "saghen/blink.cmp",
    version = '1.*',
    dependencies = {
      "mikavilpas/blink-ripgrep.nvim",
    },
    opts = {
      keymap = {
        preset = 'default',
        -- ["<C-_>"] = {
        --   function()
        --     require("blink-cmp").show({ providers = { "ripgrep" } })
        --   end,
        -- },
        ['<C-j>'] = { 'snippet_forward', 'fallback' },
        ['<C-k>'] = { 'snippet_backward', 'fallback' },
        ['<C-h>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
        ['<Tab>'] = { 'show', 'fallback' },
        ['<C-g>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-space>'] = { 'show_signature', 'hide_signature', 'fallback' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        accept = {auto_brackets = {enabled = false}},
        documentation = { auto_show = true },
        menu = { auto_show = false },
      },
      sources = {
        default = {
          'lsp', 'path', 'snippets', 'buffer'
        },
        providers = {
          -- ripgrep = {
          --   module = "blink-ripgrep",
          --   name = "Ripgrep",
          --   opts = {
          --     project_root_marker = '.git',
          --     toggles = {
          --       on_off = '<leader>sr',
          --       debug = nil,
          --     },
          --   }
          -- }
        }
      },
      fuzzy = { implementation = "rust" },
      signature = { enabled = true, },
    },
  },
}
