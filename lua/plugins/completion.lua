return {
  {
    "saghen/blink.cmp",
    event = 'InsertEnter',
    dependencies = {
      "mikavilpas/blink-ripgrep.nvim",
      "folke/snacks.nvim",
    },
    opts = {
      keymap = {
        preset = 'default',
        ['<C-j>'] = { 'snippet_forward', 'fallback' },
        ['<C-k>'] = { 'snippet_backward', 'fallback' },
        ['<C-h>'] = { 'show', 'show_documentation', 'hide_documentation' },
        ['<C-e>'] = { 'hide', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<Up>'] = { 'select_prev', 'fallback' },
        ['<Down>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback_to_mappings' },
        ['<C-n>'] = { 'select_next', 'fallback_to_mappings' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-space>'] = { 'show_signature', 'hide_signature', 'fallback' },
        ["<C-/>"] = {
          function()
            require("blink-cmp").show({ providers = { "ripgrep" } })
          end,
        },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = { documentation = { auto_show = true } },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
          ripgrep = {
            module = "blink-ripgrep",
            name = "Ripgrep",
            opts = {
              prefix_min_len = 3,
              project_root_marker = ".git",
              fallback_to_regex_highlighting = true,
              toggles = { on_off = nil, debug = nil },
              backend = {
                use = "ripgrep",
                customize_icon_highlight = true,
                ripgrep = {
                  context_size = 3,
                  max_filesize = "1M",
                  project_root_fallback = true,
                  search_casing = "--ignore-case",
                  additional_rg_options = {},
                  ignore_paths = {},
                  additional_paths = {},
                },
              },
              debug = false,
            },
          },
        }
      },
      fuzzy = { implementation = "prefer_rust_with_warning" },
      signature = {enabled = true},
    },
  }
}
